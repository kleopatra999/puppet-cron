# cron::d define - generates an /etc/cron.d file for you.
#
# Why: Because including a files makes it too easy to forget the MAILTO
#      or only put 4 *s, or any other stupid mistake.
#      Also, putting the cron command inline with the puppet code to generate
#      it generally involves less tail chasing when you're looking for a job
#
# How to use:
#
# This makes a job which runs every min, and emails systems+cron@yelp.com
# if anything is sent to stdout
# cron::d { 'minimum_example':
#     minute  => '*',
#     user    => 'push',
#     command     => '/nail/sys/bin/example_job | logger'
#  }
#
#
# Full example with all optional params:
# cron::d { 'name_of_cronjob':
#     minute  => '*',
#     hour    => '*',
#     dom     => '*',
#     month   => '*',
#     dow     => '*',
#     user    => 'bob',
#     mailto  => 'example@yelp.com',
#     command     => '/some/example/job';
# }
#
# Or you can remove a cron job:
#
# cron::d { 'minimum_example':
#     ensure  => 'absent',
#     user    => 'fred',
#     minute  => '*',
#     command     => '/nail/sys/bin/example_job | logger'
#  }
#

define cron::d (
                    $minute,
                    $command,
                    $user,
                    $hour='*',
                    $dom='*',
                    $month='*',
                    $dow='*',
                    $mailto='""',
                    $ensure='present',
                    $comment=''
                ) {
    # Deliberate copy here so we can add extra fancy options (like pipe stdout
    # to scribe) in additional parameters later
    $cmd=$command
    validate_cron_numeric($minute)
    validate_cron_numeric($hour)
    validate_cron_numeric($dom)
    validate_cron_numeric($month)
    validate_cron_numeric($dow)
    $link_ensure = $ensure ? {
      'present' => 'link',
      default   => 'absent',
    }

    $actual_cron = "/nail/etc/cron.d/${name}"

    file { "/etc/cron.d/${name}":
      ensure => $link_ensure,
      target => $actual_cron,
      owner  => 'root',
      group  => 'root',
    }

    file {"/nail/etc/cron.d/${name}":
      owner   => root,
      group   => root,
      mode    => '0444',
      content => template('cron/d.erb'),
      ensure  => $ensure;
    }
}