# inotify-ada
Ada bind inotify
## Build
```
gcc -c inotifyconstants.c
gnatmake -gnat2012 example.adb -largs inotifyconstants.o
```
