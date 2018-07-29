#include <sys/inotify.h>
#include <errno.h>

const int _IN_ACCESS = IN_ACCESS;
const int _IN_ATTRIB = IN_ATTRIB;
const int _IN_CLOSE_WRITE = IN_CLOSE_WRITE;
const int _IN_CLOSE_NOWRITE = IN_CLOSE_NOWRITE;
const int _IN_CREATE = IN_CREATE;
const int _IN_DELETE = IN_DELETE;
const int _IN_DELETE_SELF = IN_DELETE_SELF;
const int _IN_MODIFY = IN_MODIFY;
const int _IN_MOVE_SELF = IN_MOVE_SELF;
const int _IN_MOVED_FROM = IN_MOVED_FROM;
const int _IN_MOVED_TO = IN_MOVED_TO;
const int _IN_OPEN = IN_OPEN;

const int _IN_ALL_EVENTS = IN_ALL_EVENTS;

const int _IN_MOVE = IN_MOVE;
const int _IN_CLOSE = IN_CLOSE;

const int _IN_DONT_FOLLOW = IN_DONT_FOLLOW;
const int _IN_EXCL_UNLINK = IN_EXCL_UNLINK;
const int _IN_MASK_ADD = IN_MASK_ADD;
const int _IN_ONESHOT = IN_ONESHOT;
const int _IN_ONLYDIR = IN_ONLYDIR;

const int _IN_IGNORED = IN_IGNORED;
const int _IN_ISDIR = IN_ISDIR;
const int _IN_Q_OVERFLOW = IN_Q_OVERFLOW;
const int _IN_UNMOUNT = IN_UNMOUNT;

const int _IN_NONBLOCK = IN_NONBLOCK;
const int _IN_CLOEXEC = IN_CLOEXEC;

const int _ENODATA = ENODATA;

const int _EINVAL = EINVAL;
const int _EMFILE = EMFILE;
const int _ENFILE = ENFILE;
const int _ENOMEM = ENOMEM;

const int _EACCES = EACCES;
const int _EBADF = EBADF;
const int _EFAULT = EFAULT;
const int _ENAMETOOLONG = ENAMETOOLONG;
const int _ENOENT = ENOENT;
const int _ENOSPC = ENOSPC;