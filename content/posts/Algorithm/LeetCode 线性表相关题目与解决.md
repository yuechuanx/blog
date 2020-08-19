---
title: LeetCode 线性表相关题目与解决
slug: leetcode-linear-table-related-problems-and-solutions
categories:
  - Algorithm
tags:
  - algorithm
  - linear-list
  - array
date: 2020-08-14 11:19:28
---

# 线性表相关



#Array

### **[LeetCode-p1 Two Sum](https://leetcode.com/problems/two-sum/)**

**Description:**

Given an array of integers, return **indices** of the two numbers such that they add up to a specific target.

You may assume that each input would have **exactly** one solution, and you may not use the *same* element twice.

**Analysis:**

- Brute-force 
- HashMap

**Implements:**

- Cpp

~~~cpp
// Brute-force Solution
class Solution {
public:
    vector<int> twoSum(vector<int>& nums, int target) {
        vector<int> res;
        for(int i = 0; i < nums.size(); ++i) {
            for(int j = i + 1; j < nums.size(); ++j) {
                if(nums[j] == target - nums[i]) {
                    res.push_back(i);
                    res.push_back(j);
                    return res;
                }
            }
        }
        return res;
    }
};

~~~

- Java

~~~java
// Brute-force Solution
class Solution {
    public int[] twoSum(int[] nums, int target) {
        for(int i = 0; i < nums.length; i++){
            for(int j = i + 1; j < nums.length; j++){
                if(nums[j] == target - nums[i])
                    return new int[]{i,j};
            }
        }
        throw new IllegalArgumentException("No solution");
    }
}

// HashMap Solution
class Solution {
    public int[] twoSum(int[] nums, int target) {
        int[] res = new int[2];
        Map<Integer, Integer> map = new HashMap<Integer, Integer>();
        for (int i = 0; i < nums.length; ++i) {
            if (map.containsKey(target - nums[i])) {
                res[0] = i;
                res[1] = map.get(target - nums[i]);
            }
            map.put(nums[i], i);
        }
        
        return res;
    }
}
~~~

**Related Problem**

- 3Sum
- 4Sum

- Two Sum II - Input array is sorted

- Two Sum III - Data structure design

- Subarray Sum Equals K

- Two Sum IV - Input is a BST



### **LeetCode-P4 Median of Two Sorted Arrays**

**Description:**

There are two sorted arrays **nums1** and **nums2** of size m and n respectively.

Find the median of the two sorted arrays. The overall run time complexity should be O(log (m+n)).

You may assume **nums1** and **nums2** cannot be both empty.

**Analysis:**

- Merge Sort Solution
- find K-th position 

**Implements:**

- Java

~~~java
class Solution {
    public double findMedianSortedArrays(int[] nums1, int[] nums2) {
        int[] sorted = mergeSort(nums1, nums2);
        
        if (sorted.length % 2 == 1) {
            return sorted[sorted.length/2] / 1.0;
        } else {
            return (sorted[(sorted.length-1)/2] + sorted[sorted.length/2]) / 2.0;    
        }   
    }
    
    public int[] mergeSort(int[] nums1, int[] nums2) {
        int m = nums1.length, n = nums2.length;
        int total = m + n;
        
        int[] res = new int[total];
        int i = 0, j = 0, k = 0;
        
        while (i < m && j < n) {
            res[k++] = (nums1[i] < nums2[j]) ? nums1[i++] : nums2[j++];
        }
        
        for (; i < m; ++i) {
            res[k++] = nums1[i];
        }
        
        for (; j < n; ++j) {
            res[k++] = nums2[j];
        }
        
        return res;
    }
}
~~~



### **LeetCode-P11 Container With Most Water**

**Description:**

Given *n* non-negative integers *a1*, *a2*, ..., *an* , where each represents a point at coordinate (*i*, *ai*). *n* vertical lines are drawn such that the two endpoints of line *i* is at (*i*, *ai*) and (*i*, 0). Find two lines, which together with x-axis forms a container, such that the container contains the most water.

**Note:** You may not slant the container and *n* is at least 2.

**Analysis:**

- Two Pointers

**Implements:**

~~~java
class Solution {
    public int maxArea(int[] height) {
        int n = height.length;
        int left = 0, right = n - 1, maxArea = 0;
        
        while (left < right) {
            int w = right - left;
            int h = Math.min(height[left], height[right]);
            maxArea = Math.max(maxArea, w * h);
            // 高度较小的一侧决定maxArea
            if (height[left] >= height[right]) {
                right--;
            } else {
                left++;
            }
        }
        
        return maxArea;
    }
}

class Solution {
	public int maxArea(int[] height) {
		 int maxArea = 0;
        
		 for(int left = 0, right = height.length - 1; left < right; ){
			 int h = (height[left] < height[right]) ? height[left++] : height[right--];
			 maxArea = Math.max(maxArea, (right-left+1) * h);
		 }
		 
        return maxArea;
	 }
}
~~~



### **LeetCode-P15  3Sum**

**Description:**

Given an array `nums` of *n* integers, are there elements *a*, *b*, *c* in `nums` such that *a* + *b* + *c* = 0? Find all unique triplets in the array which gives the sum of zero.

**Note:**

The solution set must not contain duplicate triplets.

**Analysis:**

- Two Pointer

**Implements:**

~~~java
    public List<List<Integer>> threeSum(int[] num) {
        Arrays.sort(num);
        List<List<Integer>> res = new LinkedList<>(); 
        for (int i = 0; i < num.length-2; i++) {
            if (i == 0 || (i > 0 && num[i] != num[i-1])) {
                int lo = i+1, hi = num.length-1, sum = 0 - num[i];
                while (lo < hi) {
                    if (num[lo] + num[hi] == sum) {
                        res.add(Arrays.asList(num[i], num[lo], num[hi]));
                        do lo++; while (lo < hi && num[lo] == num[lo-1]);
                        do hi--; while (lo < hi && num[hi] == num[hi+1]);
                    } else if (num[lo] + num[hi] < sum) lo++;
                    else hi--;
               }
            }
        }
        return res;
    }
~~~

**Related Problem:**

- LeetCode-P16 3Sum Closest



### **LeetCode-P16 3Sum Closest**

**Description:**

Given an array `nums` of *n* integers and an integer `target`, find three integers in `nums` such that the sum is closest to `target`. Return the sum of the three integers. You may assume that each input would have exactly one solution.

**Analyse:**

- Brute-Force
- Two Pointers

**Implements:**

```java
// Brute-Force
class Solution {
    public int threeSumClosest(int[] nums, int target) {
        int min = Integer.MAX_VALUE, n = nums.length;
        int res = 0;
        for (int i = 0; i < n - 2; ++i) {
            for (int j = i + 1; j < n - 1; ++j) {
                for (int k = j + 1; k < n; ++k) {
                    int sum = nums[i] + nums[j] + nums[k];
                    if (Math.abs(target - sum) < min) {
                        min = Math.abs(target - sum);
                        res = sum;
                    }
                }
            }
        }

        return res;
    }
}

// Two-Pointers
class Solution {
    public int threeSumClosest(int[] nums, int target) {
        Arrays.sort(nums);
        int res = nums[0] + nums[1] + nums[nums.length - 1];
        for (int i = 0; i < nums.length - 2; ++i) {
            if (i == 0 || (i > 0 && nums[i] != nums[i-1])) {
                int lo = i + 1, hi = nums.length - 1;
                while (lo < hi) {
                    int sum = nums[i] + nums[lo] + nums[hi];
                    if (sum < target) 
                        do lo++; while (lo < hi && nums[lo] == nums[lo-1]);
                    else if (sum > target) 
                        do hi--; while (lo < hi && nums[hi] == nums[hi+1]);
                    else 
                        return sum;
                    res = (Math.abs(target-sum) < Math.abs(target-res)) ? sum : res;
                } 
            }
        }   
        return res;
    }
}
```

**Related Problem:**

- LeetCode-P15 3Sum



###**LeetCode-P18 4Sum**

**Description:**

Given an array `nums` of *n* integers and an integer `target`, are there elements *a*, *b*, *c*, and *d* in `nums` such that *a* + *b* + *c* + *d* = `target`? Find all unique quadruplets in the array which gives the sum of `target`.

**Note:**

The solution set must not contain duplicate quadruplets.

**Analysis:**

- Two Pointers

**Implements:**

**Related Problems:**



### **LeetCode-P26 Remove Duplicates from Sorted Array**

**Description:**

Given a sorted array, remove the duplicates in place such that each element appear only once
and return the new length.
Do not allocate extra space for another array, you must do this in place with constant memory.
For example, Given input array A = [1,1,2],
Your function should return length = 2, and A is now [1,2].

**Analysis:**

None

**Implements:**

~~~cpp
// Time complexity: O(n) , Space complexity: O(1)
class Solution {
public:
    int removeDuplicates(vector<int>& nums) {
        if (nums.empty()) return 0;
        int index = 0;
        for (int i = 1; i < nums.size(); i++) {
            if (nums[index] != nums[i])
            	nums[++index] = nums[i];
        }
        return index + 1;
    }
};
~~~

**Related Problems**

- 





## 单链表

