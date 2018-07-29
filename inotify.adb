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

  function "=" (a, b : file_descriptor) return boolean is
    use type gnat.os_lib.file_descriptor;
  begin
    return gnat.os_lib.file_descriptor(a) = gnat.os_lib.file_descriptor(b);
  end "=";

  function get (
      buf : buf_t; start : natural := 0;
      num : positive := int_size) return interfaces.unsigned_32 is
    use type interfaces.unsigned_32;
    result : interfaces.unsigned_32 := 0;
    ti : natural := start + buf'first;
  begin
    for i in reverse ti..ti + num loop
      result := interfaces.shift_left(result, 8);
      result := result + interfaces.unsigned_32(buf(i));
    end loop;
    return result;
  end get;

  function get_event (
      fd : file_descriptor; wd : out watch_descriptor;
      mask : out mask_t; cookie : out cookie_t;
      name : in out ada.strings.unbounded.unbounded_string) return error_t is
    use type ada.strings.unbounded.unbounded_string;
    buf : buf_t;
    ti : integer;
    len : natural;
  begin
    ti := gnat.os_lib.read(gnat.os_lib.file_descriptor(fd), buf'address, buf_size);
    if ti = -1 then
      return error_t(gnat.os_lib.errno);
    elsif ti < sizeof_struct_event then
      return ENODATA;
    end if;

    wd := watch_descriptor(get(buf));
    mask := mask_t(get(buf, int_size, uint32_size));
    cookie := cookie_t(get(buf, int_size + uint32_size, uint32_size));
    len := natural(get(buf, int_size + uint32_size * 2, uint32_size));

    for i in sizeof_struct_event..sizeof_struct_event + len loop 
      name := name & character'val(buf(i));
    end loop;

    return NO_ERROR;
  end get_event;

  function add_watch (
      fd : file_descriptor; path : string; mask : mask_t;
      wd : out watch_descriptor) return error_t is
  begin
    if path'length > MAXFILENAME then
      return ENAMETOOLONG;
    end if;
    wd := inotify_add_watch(fd, interfaces.c.strings.new_string(path), mask);
    if wd = -1 then
      return error_t(gnat.os_lib.errno);
    end if;
    return NO_ERROR;
  end add_watch;

  function rm_watch (
      fd : file_descriptor; wd : watch_descriptor) return error_t is
  begin
    if inotify_rm_watch(fd, wd) = -1 then
      return error_t(gnat.os_lib.errno);
    end if;
    return NO_ERROR;
  end rm_watch;

  function init (fd : out file_descriptor; flags : mask_t := 0) return error_t is
    use type file_descriptor;
  begin
    if flags = 0 then
      fd := inotify_init;
    else
      fd := inotify_init1(flags);
    end if;
    if fd = -1 then
      return error_t(gnat.os_lib.errno);
    end if;
    return NO_ERROR;
  end init;

  function close (fd : file_descriptor) return error_t is
  begin
    gnat.os_lib.close(gnat.os_lib.file_descriptor(fd));
    return error_t(gnat.os_lib.errno);
  end close;

end inotify;