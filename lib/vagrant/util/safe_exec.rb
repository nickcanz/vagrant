module Vagrant
  module Util
    # This module provies a `safe_exec` method which is a drop-in
    # replacement for `Kernel.exec` which addresses a specific issue
    # which manifests on OS X 10.5 and perhaps other operating systems.
    # This issue causes `exec` to fail if there is more than one system
    # thread. In that case, `safe_exec` automatically falls back to
    # forking.
    module SafeExec
      def safe_exec(command)
        fork_instead = true
        begin
          pid = nil
          pid = fork if fork_instead
          Kernel.exec(command) if pid.nil?
          Process.wait(pid) if pid
        rescue Errno::E045

          # We retried already, raise the issue and be done
          raise if fork_instead

          # The error manifested itself, retry with a fork.
          fork_instead = true
          retry
        end
      end
    end
  end
end
