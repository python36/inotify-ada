package body inotify is

  function mask_in_mask (a, b : mask_t) return boolean is
    use type interfaces.unsigned_32;
  begin
    return (a and b) = a;
  end mask_in_mask;

  function "*" (a, b : mask_t) return boolean is
  begin
    return mask_in_mask(a, b);
  end "*";

  function mask_to_mask (a, b : mask_t) return mask_t is
    use type interfaces.unsigned_32;
  begin
    return a or b;
  end mask_to_mask;

  function "+" (a, b : mask_t) return mask_t is
  begin
    return mask_to_mask(a, b);
  end "+";

  function "=" (a, b : descriptor_t) return boolean is
    use type interfaces.c_streams.files;
  begin
    return interfaces.c_streams.files(a) = interfaces.c_streams.files(b);
  end "=";

  function get_event (handle : descriptor_t) return event_t is
    use type ada.strings.unbounded.unbounded_string;
    size : system.crtl.size_t;
    e : event;
    name : interfaces.c.char_array(0..MAXFILENAME);
    result : event_t;
  begin
    size := interfaces.c_streams.fread(
      header_buf'address, system.crtl.size_t(event_io.buffer_size), 1, interfaces.c_streams.files(handle));

    event_io.read(header_buf, e);

    size := interfaces.c_streams.fread(
      name'address, 1, system.crtl.size_t(e.length), interfaces.c_streams.files(handle));

    result.wd := watch_descriptor_t(e.watch_descriptor);
    result.mask := mask_t(e.mask);
    result.cookie := cookie_t(e.cookie);
    result.name := ada.strings.unbounded.to_unbounded_string(
      interfaces.c.strings.value(interfaces.c.strings.new_char_array(name), interfaces.c.size_t(e.length)));
    return result;
  end get_event;

  function add_watch (handle : descriptor_t; path : string; mask : mask_t) return watch_descriptor_t is
    wd : watch_descriptor_t;
    error : error_t;
  begin
    if path'length > natural(MAXFILENAME) then
      ada.exceptions.raise_exception(error_nametoolong'identity, "[Rm] name too long. code: " & ENAMETOOLONG'img);
    end if;
    wd := inotify_add_watch(
      interfaces.c_streams.fileno(interfaces.c_streams.files(handle)),
      interfaces.c.strings.new_string(path), mask);
    if wd = -1 then
      error := error_t(gnat.os_lib.errno);
      if error = EACCES then
        ada.exceptions.raise_exception(error_acces'identity, "[Add] not permitted. code: " & error'img);
      elsif error = EBADF then
        ada.exceptions.raise_exception(error_badf'identity, "[Add] bad fd. code: " & error'img);
      elsif error = EFAULT then
        ada.exceptions.raise_exception(error_fault'identity, "[Add] pathname outside. code: " & error'img);
      elsif error = EINVAL then
        ada.exceptions.raise_exception(error_inval'identity, "[Add] no valid mask. code: " & error'img);
      elsif error = ENAMETOOLONG then
        ada.exceptions.raise_exception(error_nametoolong'identity, "[Add] name too long. code: " & error'img);
      elsif error = ENOENT then
        ada.exceptions.raise_exception(error_noent'identity, "[Add] does not exist or is a symlink. code: " & error'img);
      elsif error = ENOMEM then
        ada.exceptions.raise_exception(error_nomem'identity, "[Add] memory. code: " & error'img);
      elsif error = ENOSPC then
        ada.exceptions.raise_exception(error_nospc'identity, "[Add] limit. code: " & error'img);
      else
        ada.exceptions.raise_exception(error_unknown'identity, "[Add] unknown. code: " & error'img);
      end if;
    end if;
    return wd;
  end add_watch;

  procedure rm_watch (handle : descriptor_t; wd : watch_descriptor_t) is
    error : error_t;
  begin
    if inotify_rm_watch(interfaces.c_streams.fileno(interfaces.c_streams.files(handle)), wd) = -1 then
      error := error_t(gnat.os_lib.errno);
      if error = EINVAL then
        ada.exceptions.raise_exception(error_inval'identity, "[Rm] bad wd. code: " & error'img);
      elsif error = EBADF then
        ada.exceptions.raise_exception(error_badf'identity, "[Rm] bad fd. code: " & error'img);
      else
        ada.exceptions.raise_exception(error_unknown'identity, "[Init] unknown. code: " & error'img);
      end if;
    end if;
  end rm_watch;

  function init (nonblock : boolean := false; cloexec : boolean := false) return descriptor_t is
    use type interfaces.c_streams.files;
    fd : integer;
    mode : string := "r";
    handle : descriptor_t;
    flags : mask_t := 0;
    error : error_t;
  begin
    if nonblock then
      flags := flags + IN_NONBLOCK;
    end if;
    if cloexec then
      flags := flags + IN_CLOEXEC;
    end if;
    fd := inotify_init1(mask_t(flags));

    if fd = -1 then
      error := error_t(gnat.os_lib.errno);
      if error = EINVAL then
        ada.exceptions.raise_exception(error_inval'identity, "[Init] bad flags. code: " & error'img);
      elsif error = EMFILE then
        ada.exceptions.raise_exception(error_mfile'identity, "[Init] user limit. code: " & error'img);
      elsif error = ENFILE then
        ada.exceptions.raise_exception(error_nfile'identity, "[Init] system limit. code: " & error'img);
      elsif error = ENOMEM then
        ada.exceptions.raise_exception(error_nomem'identity, "[Init] memory. code: " & error'img);
      else
        ada.exceptions.raise_exception(error_unknown'identity, "[Init] unknown. code: " & error'img);
      end if;
    end if;
    handle := descriptor_t(interfaces.c_streams.fdopen(fd, mode'address));
    if interfaces.c_streams.files(handle) = interfaces.c_streams.NULL_stream then
      error := error_t(gnat.os_lib.errno);
      if error = EINVAL then
        ada.exceptions.raise_exception(error_inval'identity, "[Init] bad flags. code: " & error'img);
      else
        ada.exceptions.raise_exception(error_unknown'identity, "[Init] unknown. code: " & error'img);
      end if;
    end if;

    return handle;
  end init;

  procedure close (handle : descriptor_t) is
  begin
    if interfaces.c_streams.fclose(interfaces.c_streams.files(handle)) /= 0 then
      ada.exceptions.raise_exception(error_close'identity, "[Close] stream. code: " & error_t(gnat.os_lib.errno)'img);
    end if;
    gnat.os_lib.close(gnat.os_lib.file_descriptor(interfaces.c_streams.fileno(interfaces.c_streams.files(handle))));
  end close;

end inotify;