with ada.text_io;
with inotify;
with gnat.os_lib;
with ada.strings.unbounded;

procedure example is
  use type inotify.error_t;
  use type inotify.mask_t;
  use type inotify.file_descriptor;

  fd : inotify.file_descriptor;
  wd : inotify.watch_descriptor;
  e : inotify.error_t;
  c : inotify.cookie_t;
  m : inotify.mask_t;
  us : ada.strings.unbounded.unbounded_string;

  fd1 : inotify.file_descriptor;
begin
  e := inotify.init(fd);

  if e /= inotify.NO_ERROR then
  	ada.text_io.put("INIT Error: ");
    if inotify.EMFILE = e or inotify.ENFILE = e then
      ada.text_io.put_line("limit");
    elsif e = inotify.ENOMEM then
      ada.text_io.put_line("memory");
    else
      ada.text_io.put_line("unknown");
    end if;
    gnat.os_lib.os_exit(integer(e));
  end if;

  e := inotify.add_watch(
    fd, "/home/andrey/t1",
    inotify.IN_CREATE + inotify.IN_DELETE, wd);

  if e /= inotify.NO_ERROR then
    ada.text_io.put("ADD Error: ");
    if e = inotify.EACCES then
      ada.text_io.put_line("access");
    elsif e = inotify.ENAMETOOLONG then
      ada.text_io.put_line("nametoolong");
    elsif e = inotify.ENOENT then
      ada.text_io.put_line("path");
    else
      ada.text_io.put_line("see doc");
    end if;
    gnat.os_lib.os_exit(integer(e));
  end if; 

  e := inotify.get_event(fd, wd, m, c, us);

  if e /= inotify.NO_ERROR then
    ada.text_io.put_line("READ Error");
    gnat.os_lib.os_exit(integer(e));
  end if;

  if inotify.IN_ISDIR * m then
    ada.text_io.put("directory ");
  end if;

  if inotify.IN_CREATE * m then
    ada.text_io.put("create: ");
  elsif inotify.IN_DELETE * m then
    ada.text_io.put("delete: ");
  else
    ada.text_io.put("unknown: ");
  end if;
  ada.text_io.put_line(ada.strings.unbounded.to_string(us));

  e := inotify.rm_watch(fd, wd);

  if e /= inotify.NO_ERROR then
    ada.text_io.put_line("RM Error");
    gnat.os_lib.os_exit(integer(e));
  end if;

  e := inotify.close(fd);

  if e /= inotify.NO_ERROR then
    ada.text_io.put_line("CLOSE Error");
    gnat.os_lib.os_exit(integer(e));
  end if;

  if fd1 = fd then
    null;
  end if;

end example;