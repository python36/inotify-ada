# inotify-ada
Bind inotify to Ada
## Build
```
gcc -c inotifyconstants.c
gnatmake -gnat2012 example.adb -largs inotifyconstants.o
```
