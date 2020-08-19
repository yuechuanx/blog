---
title: <深入理解JVM> 函数调用机制
toc: true
categories:
  - Java
tags:
  - jvm
translate_title: u003cindepth-understanding-of-jvmu003e-function-call-mechanism
date: 2018-11-27 19:48:56
---


## C语言函数调用实现

通过一个简单的C语言程序分析
~~~c
#include <stdio.h>

int add();

int main(int argc, char const *argv[])
{
    int c = add();
    printf("%d", c);
    return 0;
}

int add() {
    int z = 1 + 2;
    return z;
}

~~~

将这段C程序编译成汇编程序：

~~~asm
	.file	".\\sampleAdd.c"
	.section	.rodata
.LC0:
	.string	"%d"
	.text
	.globl	main
	.type	main, @function
main:
.LFB13:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movl	%edi, -20(%rbp)
	movq	%rsi, -32(%rbp)
	movl	$0, %eax
	call	add
	movl	%eax, -4(%rbp)
	movl	-4(%rbp), %eax
	movl	%eax, %esi
	movl	$.LC0, %edi
	movl	$0, %eax
	call	printf
	movl	$0, %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE13:
	.size	main, .-main
	.globl	add
	.type	add, @function
add:
.LFB14:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	$3, -4(%rbp)
	movl	-4(%rbp), %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE14:
	.size	add, .-add
	.ident	"GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.11) 5.4.0 20160609"
	.section	.note.GNU-stack,"",@progbits

~~~

去除宏定义，保留主要指令如下：

~~~asm
main:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$32, %rsp
	movl	%edi, -20(%rbp)
	movq	%rsi, -32(%rbp)
	movl	$0, %eax
	call	add
	movl	%eax, -4(%rbp)
	movl	-4(%rbp), %eax
	movl	%eax, %esi
	movl	$.LC0, %edi
	movl	$0, %eax
	call	printf
	movl	$0, %eax
	leave
	ret
add:
	pushq	%rbp
	movq	%rsp, %rbp
	movl	$3, -4(%rbp)
	movl	-4(%rbp), %eax
	popq	%rbp
	ret
~~~

汇编程序有两个标号`main`, `add`。这不是巧合，而是编译器处理的结果，**编译器会把函数名处理成汇编程序中的标号**。 有了标号，汇编程序就能执行函数调用，即call指令，有一条`call and`指令，就是汇编中执行函数调用的指令。

接下来逐段分析：

~~~asm
	# 保存调用者栈基地址，并为main()函数分配新栈空间
	pushq	%rbp	
	movq	%rsp, %rbp
	subq	$32, %rsp	# 分配新栈，一共32字节
~~~

在`mian`，`add`代码段的开始都包含这3条指令，add代码段第3行是`movl	$3, -4(%rbp)`该指令与`mian`代码段的`subq	$32, %rsp`作用是相同的——分配栈空间。

这3条指令的作用为：保存段调用者基址，为新方法分配方法栈。这几乎是汇编程序执行方法调用的标准定式。

`main()` 函数的方法栈内存布局如下图所示：

// 这里需要插入一张图片



### 带入参的C程序

~~~c
#include <stdio.h>

int add(int a, int b);

int main(int argc, char const *argv[])
{
    int a = 5, b = 3;
    int c = add(a, b);
    return 0;
}

int add(int a, int b) {
    int z = 1 + 2;
    return z;
}

~~~

将这段C程序编译成汇编程序(**去除宏定义，保留主要指令**)：

~~~asm
main:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$32, %rsp
	movl	%edi, -20(%rbp)
	movq	%rsi, -32(%rbp)
	movl	$5, -12(%rbp)
	movl	$3, -8(%rbp)
	movl	-8(%rbp), %edx
	movl	-12(%rbp), %eax
	movl	%edx, %esi
	movl	%eax, %edi
	call	add
	movl	%eax, -4(%rbp)
	movl	$0, %eax
	leave
	ret
add:
	pushq	%rbp
	movq	%rsp, %rbp
	movl	%edi, -20(%rbp)
	movl	%esi, -24(%rbp)
	movl	$3, -4(%rbp)
	movl	-4(%rbp), %eax
	popq	%rbp
	ret
~~~

## C语言函数的调用机制

1. 压栈
main函数调用add()函数之前，会将两个入参压栈（压入调用者的栈），压栈之后add()就可以获取这两个入参。
2. 参数传递顺序
Linux平台，调用者函数向被调用者函数传递参数，采用逆向顺序压栈，即最后一个参数第一个压栈，第一个参数最后压栈
3. 读取入参
读取入参的方式是：通过add()函数的栈基地址rbp的相对地址，从main()函数中读取，最后一位入参在8(%rbp)，依次12(%rbp)......


## 真实物理机器上执行函数调用的步骤：

1. 保存调用者栈基地址，当前IP寄存器入栈
2. 调用函数时，在x86平台参数从右到左依次入栈
3. 一个方法所分配的栈空间大小，取决于方法内部局部变量空间、为被调用者所传递的入参大小
4. 被调用者在接收入参时，从8(%rbp)处开始，往上逐个获取参数
5. 被调用者将返回结果保存在eax寄存器中，调用者从该寄存器取值



## 补充（关于寄存器）

- %rax 作为函数返回值使用。
- %rsp 栈指针寄存器，指向栈顶
- %rdi，%rsi，%rdx，%rcx，%r8，%r9 用作函数参数，依次对应第1参数，第2参数。。。
- %rbx，%rbp，%r12，%r13，%14，%15 用作数据存储，遵循被调用者使用规则，简单说就是随便用，调用子函数之前要备份它，以防他被修改
- %r10，%r11 用作数据存储，遵循调用者使用规则，简单说就是使用之前要先保存原值



## Reference

- [X86-64寄存器和栈帧](http://ju.outofmemory.cn/entry/769)

- 揭秘Java虚拟机 
