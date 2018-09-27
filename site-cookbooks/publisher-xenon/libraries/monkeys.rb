
# Chef 13 has a bug with Ubuntu 18.04 where it runs `update-rc.d -n`, but -n
# was removed from update-rc.d. This results in calls failing for no good
# reason. Hack around this by monkey patching the -n out of shell calls.
class Chef
  class Provider
    class Service
      class Debian
        alias orig_shell_out! shell_out!
        def shell_out!(*args)
          arg = args[0]
          return orig_shell_out!(*args) unless arg.include?('update-rc.d')
          arg.sub!(' -n ', ' ') # this is in-place (in the array)
          orig_shell_out!(*args)
        end
      end
    end
  end
end
