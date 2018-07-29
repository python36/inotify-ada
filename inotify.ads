with gnat.os_lib;
with interfaces;
with interfaces.c;
with interfaces.c.strings;
with ada.strings.unbounded;

package inotify is
  type file_descriptor is limited private;
  type watch_descriptor is new interfaces.c.int;
  type mask_t is new interfaces.unsigned_32;
  type cookie_t is new interfaces.unsigned_32;
  type error_t is new integer;

  ----------
  -- init --
  ----------
  function init (fd : out file_descriptor; flags : mask_t := 0) return error_t;
  -- flags: IN_NONBLOCK, IN_CLOEXEC
  -- errors: EINVAL, EMFILE, EMFILE, ENFILE, ENOMEM

  ---------------
  -- add_watch --
  ---------------
  function add_watch (
    fd : file_descriptor; path : string; mask : mask_t;
    wd : out watch_descriptor ) return error_t;
  -- masks: IN_ACCESS, IN_ATTRIB, IN_CLOSE_WRITE, IN_CLOSE_NOWRITE, IN_CREATE,
  --        IN_DELETE, IN_DELETE_SELF, IN_MODIFY, IN_MOVE_SELF, IN_MOVED_FROM,
  --        IN_MOVED_TO, IN_OPEN,
  --        IN_ALL_EVENTS, IN_MOVE, IN_CLOSE,
  --        IN_DONT_FOLLOW, IN_EXCL_UNLINK, IN_MASK_ADD, IN_ONESHOT, IN_ONLYDIR
  -- errors: EACCES, EBADF, EFAULT, EINVAL, ENAMETOOLONG, ENOENT, ENOMEM, ENOSPC

  ----------
  -- read --
  ----------
  function get_event (
      fd : file_descriptor; wd : out watch_descriptor;
      mask : out mask_t; cookie : out cookie_t;
      name : in out ada.strings.unbounded.unbounded_string) return error_t;
  -- masks: IN_ACCESS, IN_ATTRIB, IN_CLOSE_WRITE, IN_CLOSE_NOWRITE, IN_CREATE,
  --        IN_DELETE, IN_DELETE_SELF, IN_MODIFY, IN_MOVE_SELF, IN_MOVED_FROM,
  --        IN_MOVED_TO, IN_OPEN,
  --        IN_IGNORED, IN_ISDIR, IN_Q_OVERFLOW, IN_UNMOUNT
  -- errors: EBADF, EFAULT, EINVAL, EINVAL

  --------------
  -- rm_watch --
  --------------
  function rm_watch (
    fd : file_descriptor; wd : watch_descriptor) return error_t;
  -- errors: EBADF, EINVAL

  function close (fd : file_descriptor) return error_t;
  -- When all file descriptors referring to an inotify instance have been closed,
  -- the underlying object and its resources are freed for reuse by the kernel;
  -- all associated watches are automatically freed
  -- errors: EBADF, ENOSPC

  ---------------------
  -- file_descriptor --
  ---------------------
  function "=" (a, b : file_descriptor) return boolean;

  -----------
  -- masks --
  -----------
  function mask_in_mask (a, b : mask_t) return boolean; -- a in b?
  function "*" (a, b : mask_t) return boolean; -- mask_in_mask

  function mask_to_mask (a, b : mask_t) return mask_t; -- a = a | b;
  function "+" (a, b : mask_t) return mask_t; -- mask_to_mask

  NO_ERROR : constant error_t := 0;
  ------------
  -- Events --
  ------------                                  
  IN_ACCESS : constant mask_t;-- File was accessed (e.g., read(2), execve(2)).

  IN_ATTRIB : constant mask_t; -- Metadata changed—for example, permissions (e.g.,
    -- chmod(2)), timestamps (e.g., utimensat(2)), extended attributes (setxattr(2)),
    -- link count (since Linux 2.6.25; e.g., for the target of link(2) and 
    -- for unlink(2)), and user/group ID (e.g., chown(2)).

  IN_CLOSE_WRITE : constant mask_t; -- File opened for writing was closed.

  IN_CLOSE_NOWRITE : constant mask_t; -- File or directory not opened for writing was closed.

  IN_CREATE : constant mask_t; -- File/directory created in watched directory (e.g., open(2)
    -- O_CREAT, mkdir(2), link(2), symlink(2), bind(2) on a UNIX domain socket).

  IN_DELETE : constant mask_t; -- File/directory deleted from watched directory.

  IN_DELETE_SELF : constant mask_t; -- Watched file/directory was itself deleted. (This event
    -- also occurs if an object is moved to another filesystem, since mv(1) in effect copies
    -- the file to the other filesystem and then deletes it from the original filesys‐tem.)
    -- In addition, an IN_IGNORED event will subsequently be generated for the watch descriptor.

  IN_MODIFY : constant mask_t; -- File was modified (e.g., write(2), truncate(2)).

  IN_MOVE_SELF : constant mask_t; -- Watched file/directory was itself moved.

  IN_MOVED_FROM : constant mask_t; -- Generated for the directory containing the old filename
    -- when a file is renamed.

  IN_MOVED_TO : constant mask_t; -- Generated for the directory containing the new filename
    -- when a file is renamed.

  IN_OPEN : constant mask_t; -- File or directory was opened.

  -- All events
  IN_ALL_EVENTS : constant mask_t; -- macro is defined as a bit mask of all of the above events.

  -- Two additional convenience macros are defined:
  IN_MOVE : constant mask_t; -- Equates to IN_MOVED_FROM | IN_MOVED_TO.

  IN_CLOSE : constant mask_t; -- Equates to IN_CLOSE_WRITE | IN_CLOSE_NOWRITE.

  -- The following further bits can be specified in mask when calling add_match:
  IN_DONT_FOLLOW : constant mask_t; -- Don't dereference pathname if it is a symbolic link.

  IN_EXCL_UNLINK : constant mask_t; -- By default, when watching events on the children of a
    -- directory, events are generated for children even after they have been unlinked from
    -- the directory. This can result in large numbers of uninteresting events for some
    -- applications (e.g., if watching /tmp, in which many applications create temporary
    -- files whose names are immediately unlinked). Specifying IN_EXCL_UNLINK changes the default
    -- behavior, so that events are not generated for children after they have been unlinked
    -- from the watched directory.

  IN_MASK_ADD : constant mask_t; -- If a watch instance already exists for the filesystem
    -- object corresponding to pathname, add (OR) the events in mask to the watch mask
    -- (instead of replacing the mask).

  IN_ONESHOT : constant mask_t; -- Monitor the filesystem object corresponding to pathname
    -- for one event, then remove from watch list.

  IN_ONLYDIR : constant mask_t; -- Watch pathname only if it is a directory. Using this flag 
    -- provides an application with a race-free way of ensuring that the monitored object
    -- is a directory.

  -- The following bits may be set in the mask field returned by read(2):
  IN_IGNORED : constant mask_t; -- Watch was removed explicitly (inotify_rm_watch(2)) or
    -- automatically (file was deleted, or filesystem was unmounted).  See also BUGS.

  IN_ISDIR : constant mask_t; -- Subject of this event is a directory.

  IN_Q_OVERFLOW : constant mask_t; -- Event queue overflowed (wd is -1 for this event).

  IN_UNMOUNT : constant mask_t; -- Filesystem containing watched object was unmounted.  In
    -- addition, an IN_IGNORED event will subsequently be generated for the watch descriptor.

  -- Flags init:
  IN_NONBLOCK : constant mask_t; -- Set the O_NONBLOCK file status flag on the new open file
    -- description.  Using this flag saves extra calls to fcntl(2) to achieve the same result.

  IN_CLOEXEC : constant mask_t; -- Set the close-on-exec (FD_CLOEXEC) flag on the new file
    -- descriptor.  See the description of the O_CLOEXEC flag in open(2) for reasons why
    -- this may be useful.

  ------------
  -- Errors --
  ------------

  ENODATA : constant error_t; -- No message is available

  EINVAL : constant error_t; -- The given event mask contains no valid events; or fd is not an
    -- inotify file descriptor.

  EMFILE : constant error_t; -- The user limit on the total number of inotify instances has
    -- been reached.
    -- The per-process limit on the number of open file descriptors has been reached.

  ENFILE : constant error_t; -- The system-wide limit on the total number of open files has
    --been reached.

  ENOMEM : constant error_t; -- Insufficient kernel memory is available.

  EACCES : constant error_t; -- Read access to the given file is not permitted.

  EBADF : constant error_t; -- The given file descriptor is not valid.

  EFAULT : constant error_t; -- pathname points outside of the process's accessible address space.

  ENAMETOOLONG : constant error_t; -- pathname is too long.

  ENOENT : constant error_t; -- A directory component in pathname does not exist or is a
    -- dangling symbolic link.

  ENOSPC : constant error_t; -- The user limit on the total number of inotify watches was
    -- reached or the kernel failed to allocate a needed resource.

private

  type file_descriptor is new gnat.os_lib.file_descriptor;
  MAXFILENAME : constant natural := 256;
  int_size : constant positive := interfaces.c.int'size / 8;
  uint32_size : constant positive := interfaces.unsigned_32'size / 8;
  sizeof_struct_event : constant positive := int_size + uint32_size * 3;
  buf_size : constant positive := sizeof_struct_event + MAXFILENAME * 2 + 1;
  type buf_t is array (0..buf_size - 1) of interfaces.unsigned_8;
  pragma convention (c, buf_t);
  for buf_t'component_size use interfaces.unsigned_8'size;

  function inotify_init return file_descriptor;
  pragma import (c, inotify_init, "inotify_init");

  function inotify_init1 (flags : mask_t) return file_descriptor;
  pragma import (c, inotify_init1, "inotify_init1");

  function inotify_add_watch (
    fd : file_descriptor; pathname : interfaces.c.strings.chars_ptr;
    mask : mask_t) return watch_descriptor;
  pragma import (c, inotify_add_watch, "inotify_add_watch");

  function inotify_rm_watch (
    fd : file_descriptor;
    wd : watch_descriptor) return error_t;
  pragma import (c, inotify_rm_watch, "inotify_rm_watch");

  pragma import (C, IN_ACCESS, "_IN_ACCESS");
  pragma import (C, IN_CREATE, "_IN_CREATE");
  pragma import (C, IN_ATTRIB, "_IN_ATTRIB");
  pragma import (C, IN_CLOSE_WRITE, "_IN_CLOSE_WRITE");
  pragma import (C, IN_CLOSE_NOWRITE, "_IN_CLOSE_NOWRITE");
  pragma import (C, IN_DELETE, "_IN_DELETE");
  pragma import (C, IN_DELETE_SELF, "_IN_DELETE_SELF");
  pragma import (C, IN_MODIFY, "_IN_MODIFY");
  pragma import (C, IN_MOVE_SELF, "_IN_MOVE_SELF");
  pragma import (C, IN_MOVED_FROM, "_IN_MOVED_FROM");
  pragma import (C, IN_MOVED_TO, "_IN_MOVED_TO");
  pragma import (C, IN_OPEN, "_IN_OPEN");
  pragma import (C, IN_ALL_EVENTS, "_IN_ALL_EVENTS");
  pragma import (C, IN_MOVE, "_IN_MOVE");
  pragma import (C, IN_CLOSE, "_IN_CLOSE");
  pragma import (C, IN_DONT_FOLLOW, "_IN_DONT_FOLLOW");
  pragma import (C, IN_EXCL_UNLINK, "_IN_EXCL_UNLINK");
  pragma import (C, IN_MASK_ADD, "_IN_MASK_ADD");
  pragma import (C, IN_ONESHOT, "_IN_ONESHOT");
  pragma import (C, IN_ONLYDIR, "_IN_ONLYDIR");
  pragma import (C, IN_IGNORED, "_IN_IGNORED");
  pragma import (C, IN_ISDIR, "_IN_ISDIR");
  pragma import (C, IN_Q_OVERFLOW, "_IN_Q_OVERFLOW");
  pragma import (C, IN_UNMOUNT, "_IN_UNMOUNT");
  pragma import (C, IN_NONBLOCK, "_IN_NONBLOCK");
  pragma import (C, IN_CLOEXEC, "_IN_CLOEXEC");
  pragma import (C, ENODATA, "_ENODATA");
  pragma import (C, EINVAL, "_EINVAL");
  pragma import (C, EMFILE, "_EMFILE");
  pragma import (C, ENFILE, "_ENFILE");
  pragma import (C, ENOMEM, "_ENOMEM");
  pragma import (C, EACCES, "_EACCES");
  pragma import (C, EBADF, "_EBADF");
  pragma import (C, EFAULT, "_EFAULT");
  pragma import (C, ENAMETOOLONG, "_ENAMETOOLONG");
  pragma import (C, ENOENT, "_ENOENT");
  pragma import (C, ENOSPC, "_ENOSPC");

end inotify;