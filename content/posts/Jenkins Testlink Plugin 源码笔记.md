---
title: Jenkins Testlink Plugin 源码笔记
slug: jenkins-testlink-plugin-source-notes
date: 2020-08-14 11:12:59
---
# Jenkins Testlink Plugin 源码笔记

## 需求

Testlink 的 testcase 可以通过 Jenkins 去执行，当 Jenkins job 执行完之后，可以将执行结果保存到 Testlink 中。

jenkins 中 testlink plugin 仅仅可以在 freestyle 项目类型中使用，但目前大多数的 job 已经转移到 pipeline 类型，所以 testlink plugin 支持 pipeline 是一个自然的需要。

## 思路

首先查到官方 Testlink-plugin 的 repo https://github.com/jenkinsci/testlink-plugin

pull 到本地查看一下项目结构

~~~bash
├── pom.xml 						
├── src									
│   ├── main
│   │   ├── java
│   │   ├── resources
│   │   └── webapp
│   └── test
│       ├── java
│       └── resources

~~~

其中主要代码存放在 src/main/hudson/plugins/testlink 下：

~~~bash
├── AbstractTestLinkBuilder.java
├── AbstractTestLinkProjectAction.java
├── GraphHelper.java
├── Report.java
├── TestLinkBuildAction.java
├── TestLinkBuilder.java
├── TestLinkBuilderDescriptor.java
├── TestLinkInstallation.java
├── TestLinkJunitWrapper.java
├── TestLinkProjectAction.java
├── TestLinkResult.java
├── TestLinkSite.java
├── result
│   ├── AbstractJUnitResultSeeker.java
│   ├── AbstractTAPFileNameResultSeeker.java
│   ├── AbstractTestNGResultSeeker.java
│   ├── JUnitCaseClassNameResultSeeker.java
│   ├── JUnitCaseNameResultSeeker.java
│   ├── JUnitMethodNameResultSeeker.java
│   ├── JUnitSuiteNameResultSeeker.java
│   ├── ResultSeeker.java
│   ├── ResultSeekerDescriptor.java
│   ├── ResultSeekerException.java
│   ├── TAPFileNameMultiTestPointsResultSeeker.java
│   ├── TAPFileNameResultSeeker.java
│   ├── TestCaseWrapper.java
│   ├── TestNGClassNameResultSeeker.java
│   ├── TestNGMethodNameDataProviderNameResultSeeker.java
│   ├── TestNGMethodNameResultSeeker.java
│   └── TestNGSuiteNameResultSeeker.java
└── util
    ├── ExecutionOrderComparator.java
    └── TestLinkHelper.java


~~~

现在可以来对代码进行分析了，首先我们寻找到调用的入口 TestlinkBuilder.java

定位到 `perfrom()` 函数

~~~java
public boolean perform(AbstractBuild<?, ?> build, Launcher launcher, BuildListener listener) throws InterruptedException, IOException {
	// function body		
}
~~~

可以看到入参列表：

`AbstractBuild<?, ?> build` 

`Launcher`

`BuildListener `

接下来看函数体内容：

~~~java
// TestLink installation
listener.getLogger().println(Messages.TestLinkBuilder_PreparingTLAPI());
final TestLinkInstallation installation = DESCRIPTOR
.getInstallationByTestLinkName(this.testLinkName);
if (installation == null) {
throw new AbortException(Messages.TestLinkBuilder_InvalidTLAPI());
}

~~~

TestlinkInstallation 保存 configuration 里面对 Testlink 的配置信息:

包括 `name`, `url`, `devKey`, `testlinkJavaAPIPr	operties`

接下来是初始化其他的东西

~~~java
TestLinkHelper.setTestLinkJavaAPIProperties(installation.getTestLinkJavaAPIProperties(), listener);

final TestLinkSite testLinkSite;
final TestCaseWrapper[] automatedTestCases;
final String testLinkUrl = installation.getUrl();
final String testLinkDevKey = installation.getDevKey();
TestPlan testPlan;
listener.getLogger().println(Messages.TestLinkBuilder_UsedTLURL(testLinkUrl));
...
testLinkSite = this.getTestLinkSite(testLinkUrl, testLinkDevKey, testProjectName, testPlanName, platformName, buildName, buildCustomFields, buildNotes);
~~~

`TestlinkSite` 成员里有 `TestlinkAPI`, 可以通过传入 configuration 里面所设置的参数对 `Testlink` 进行操作。

~~~java
final String[] testCaseCustomFieldsNames = TestLinkHelper.createArrayOfCustomFieldsNames(build.getBuildVariableResolver(), build.getEnvironment(listener), this.getCustomFields());
// Array of automated test cases
TestCase[] testCases = testLinkSite.getAutomatedTestCases(testCaseCustomFieldsNames);

// Retrieve custom fields in test plan
final String[] testPlanCustomFieldsNames = TestLinkHelper.createArrayOfCustomFieldsNames(build.getBuildVariableResolver(), build.getEnvironment(listener), this.getTestPlanCustomFields());
testPlan = testLinkSite.getTestPlanWithCustomFields(testPlanCustomFieldsNames);

// Transforms test cases into test case wrappers
automatedTestCases = this.transform(testCases);
~~~

获取 `CustomFields` ， 通过`TestlinkSite` 拿到对应的 `(List)Testcase`，转换为`(List)TestlinkWrapper `,  针对其进行了一层封装，具体细节看 `result/TestcaseWrapper.java`. 

~~~java
for(TestCaseWrapper tcw : automatedTestCases) {
  testLinkSite.getReport().addTestCase(tcw);
  if(LOGGER.isLoggable(Level.FINE)) {
    LOGGER.log(Level.FINE, "TestLink automated test case ID [" + tcw.getId() + "], name [" +tcw.getName()+ "]");
  }
}
~~~

`TestSite`中有成员 `Report`，用来存储基本的 Testcase，以及 TestStatus 这些信息

~~~java
if(getResultSeekers() != null) {
  for (ResultSeeker resultSeeker : getResultSeekers()) {
    LOGGER.log(Level.INFO, "Seeking test results. Using: " + resultSeeker.getDescriptor().getDisplayName());
    resultSeeker.seek(automatedTestCases, build, build.getWorkspace(), launcher, listener, testLinkSite);
  }
}
~~~

`ResultSeeker` 通过执行测试用例得到的 *report.xml 文件解析得到相应 Testcase 的执行结果。

~~~java
final Report report = testLinkSite.getReport();
report.tally();
...
final TestLinkResult result = new TestLinkResult(report);
final TestLinkBuildAction buildAction = new TestLinkBuildAction(result);
build.addAction(buildAction);
~~~

最后一步，生成 TestlinkReport，这里的对应的是 Jenkins 显示的report，而不是 TestlinkAPI 的 report。

执行逻辑结束。

## 后记

在完成这篇文章之前，我对于能否清晰的表达出我的分析有很大的怀疑。我之前也曾阅读过源码，是关于数据结构的。针对大的，互相有依赖的，以一定代码规模的，我不曾分析过。

在阅读源码的时候，获得了以下几个小的知识点

- 从入口到各个模块的调用，是阅读源码的脉络
- 不要一开始纠结于细节。大致了解各个功能模块的作用就行
- 良好的抽象能力是关键技能