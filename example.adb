with ada.text_io;
with inotify;
with gnat.os_lib;
with ada.strings.unbounded;

procedure example is
  use type inotify.mask_t;
  use type inotify.event_t;
  use type inotify.watch_descriptor_t;

  handle : inotify.descriptor_t;
  wd : inotify.watch_descriptor_t;
  event : inotify.event_t;

begin
  handle := inotify.init;
  wd := handle.add_watch("/media/gs/DA84-0C6A/preseed", inotify.IN_ALL_EVENTS);

  loop
    event := handle.get_event;
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

  handle.close;
end example;
