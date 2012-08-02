require 'tmpdir'
require 'fileutils'

require File.expand_path('../lib/wamqg/version', __FILE__)

namespace :deb do

  desc 'Creates a debian package out of the current git HEAD'
  task :create do
    Dir.mktmpdir do |tmpdir|
      Dir.mkdir File.join(tmpdir, 'DEBIAN')

      File.open(File.join(tmpdir, 'DEBIAN/control'), 'w+') do |f|
        f << <<FILE
Package: wamqg
Priority: optional
Section: admin
Maintainer: #{ENV['USER']}
Architecture: all
Version: 0.1
Installed-Size: 40
Description: wamqg
FILE
      end

      File.open(File.join(tmpdir, 'DEBIAN/postinst'), 'w+') do |f|
        f << <<FILE
#!/bin/sh

update-rc.d -f wamqg defaults
chown -R root:root /usr/share/wamqg

/etc/init.d/wamqg start
FILE
      end

      File.open(File.join(tmpdir, 'DEBIAN/prerm'), 'w+') do |f|
        f << <<FILE
#!/bin/sh

/etc/init.d/wamqg stop

update-rc.d -f wamqg remove
FILE
      end

      FileUtils.mkdir_p File.join(tmpdir, "etc/init.d/")

      File.open(File.join(tmpdir, 'etc/init.d/wamqg'), 'w+') do |f|
        f << <<FILE
#!/bin/sh
### BEGIN INIT INFO
# Provides:          wamqg
# Required-Start:    $local_fs $remote_fs $network $syslog $named
# Required-Stop:     $local_fs $remote_fs $network $syslog $named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# X-Interactive:     true
# Short-Description: start/stop wamqg
### END INIT INFO

case "$1" in
  start)
    bash -c "source /usr/local/rvm/scripts/rvm; cd /usr/share/wamqg; bundle install --deployment;"
    bash -c "source /usr/local/rvm/scripts/rvm; cd /usr/share/wamqg; bin/wamqg_ctl start"
  ;;
  stop)
    bash -c "source /usr/local/rvm/scripts/rvm; cd /usr/share/wamqg; bin/wamqg_ctl stop"
  ;;
  restart)
    bash -c "source /usr/local/rvm/scripts/rvm; cd /usr/share/wamqg; bin/wamqg_ctl restart"
  ;;
esac

exit 0
FILE
      end

      FileUtils.mkdir_p File.join(tmpdir, "usr/share/wamqg")

      system "git archive HEAD | tar xC #{File.join(tmpdir, "usr/share/wamqg")}"

      system "chmod 755 #{File.join(tmpdir, "DEBIAN/postinst")}"
      system "chmod 755 #{File.join(tmpdir, "DEBIAN/prerm")}"
      system "chmod 755 #{File.join(tmpdir, "etc/init.d/wamqg")}"
      system "chmod 755 #{File.join(tmpdir, "usr/share/wamqg/bin/wamqg_ctl")}"
      system "dpkg -b #{tmpdir} wamqg-#{Wamqg::VERSION}.deb"
    end
  end

end
