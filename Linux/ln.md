# default usage
## create Hard Links
```
ln source_file target_file
```
examples
```
$ ls -la
total 8
drwxr-xr-x 2 doro doro 4096 Jun  2 21:57 .
drwxrwxrwt 4 root root 4096 Jun  2 21:57 ..
-rw-r--r-- 1 doro doro    0 Jun  2 21:57 test1
-rw-r--r-- 1 doro doro    0 Jun  2 21:57 test2
-rw-r--r-- 1 doro doro    0 Jun  2 21:57 test3
$
$ ln test1 test4
$
$ ls -li
total 0
2344 -rw-r--r-- 2 doro doro 0 Jun  2 21:57 test1
2345 -rw-r--r-- 1 doro doro 0 Jun  2 21:57 test2
2346 -rw-r--r-- 1 doro doro 0 Jun  2 21:57 test3
2344 -rw-r--r-- 2 doro doro 0 Jun  2 21:57 test4     # <- inode number is the same as t est1
```

## create symbolic Links
```
ln -s test1 test5
```
examples
```
$ ls -l
total 0
-rw-r--r-- 2 doro doro 0 Jun  2 21:57 test1
-rw-r--r-- 1 doro doro 0 Jun  2 21:57 test2
-rw-r--r-- 1 doro doro 0 Jun  2 21:57 test3
-rw-r--r-- 2 doro doro 0 Jun  2 21:57 test4
$
$ ln -s test1 test5
$
$ ls -l
total 0
-rw-r--r-- 2 doro doro 0 Jun  2 21:57 test1
-rw-r--r-- 1 doro doro 0 Jun  2 21:57 test2
-rw-r--r-- 1 doro doro 0 Jun  2 21:57 test3
-rw-r--r-- 2 doro doro 0 Jun  2 21:57 test4
lrwxrwxrwx 1 doro doro 5 Jun  2 22:08 test5 -> test1
```
