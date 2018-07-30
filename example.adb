with ada.text_io;
with inotify;
with gnat.os_lib;
with ada.strings.unbounded;

procedure example is
  use type inotify.mask_t;
  use type inotify.event_t;

  handle : inotify.descriptor_t;
  wd : inotify.watch_descriptor_t;
  event : inotify.event_t;

begin
  handle := inotify.init;
  wd := inotify.add_watch(handle, "/home/gs/t2",
    inotify.IN_CREATE + inotify.IN_DELETE + inotify.IN_DELETE_SELF);

  loop
    event := inotify.get_event(handle);
    ada.text_io.put(ada.strings.unbounded.to_string(event.name));

    if event /= inotify.event_null then
      if inotify.IN_ISDIR * event.mask then
        ada.text_io.put(" directory ");
      end if;

      if inotify.IN_CREATE * event.mask then
        ada.text_io.put_line(" create");
      elsif inotify.IN_DELETE * event.mask then
        ada.text_io.put_line(" delete");
      elsif inotify.IN_DELETE_SELF * event.mask then
        ada.text_io.put_line(" delete self");
        exit;
      end if;
    end if;

  end loop;

  inotify.close(handle);
end example;
