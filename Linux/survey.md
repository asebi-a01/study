# Display all files including hidden files
```
ls -la
```
# Display the contents of a directory recursively
```
ls -lR
```
show all files including hidden files
```
ls -laR
```

# List the directories under the specified directory with full paths.

## Only Direcotry
```
find /tmp -type d -exec ls -ld {} \;
```
examples
```
$ find /tmp -type d -exec ls -ld {} \;
drwxrwxrwt 4 root root 4096 Jun  2 21:57 /tmp
drwxrwxrwx 2 root root 60 Jun  2 21:21 /tmp/.X11-unix
drwxr-xr-x 2 doro doro 4096 Jun  2 22:08 /tmp/test
$
```

## Only File
```
find /tmp -type f -exec ls -ld {} \;
```
examples
```
$ find /tmp -type f -exec ls -ld {} \;
-rw-r--r-- 2 doro doro 0 Jun  2 21:57 /tmp/test/test4
-rw-r--r-- 2 doro doro 0 Jun  2 21:57 /tmp/test/test1
-rw-r--r-- 1 doro doro 0 Jun  2 21:57 /tmp/test/test2
-rw-r--r-- 1 doro doro 0 Jun  2 21:57 /tmp/test/test3
$
```


### Displays the total size from the specified directory down.
```
df -h /tmp
```

### find a desired file from below a specified directory
```
find /tmp -name "test.txt"
```