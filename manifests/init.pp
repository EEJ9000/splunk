# == Class: splunk
#
# Full description of class splunk here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { splunk: type => 'forwarder' }
#
# === Authors
#
# Christopher Caldwell <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
class splunk($type='forwarder') {

  include splunk::params

  $version         = $::splunk::params::version
  $splunk_user     = $::splunk::params::splunk_user
  $splunk_group    = $::splunk::params::splunk_group
  $install_path    = $::splunk::params::install_path
  $current_version = $::splunk_version
  $service_url     = $::fqdn
  $splunkos        = $::splunk::params::splunkos
  $splunkarch      = $::splunk::params::splunkarch
  $splunkext       = $::splunk::params::splunkext
  $tar             = $::splunk::params::tar
  $tarcmd          = $::splunk::params::tarcmd

  if $type == 'forwarder' {
    $sourcepart = 'splunkforwarder'
  } else {
    $sourcepart = 'splunk'
  }

  $splunkhome   = "${install_path}/${sourcepart}"
  $local_path   = "${splunkhome}/etc/system/local"
  $splunkdb     = "${splunkhome}/var/lib/splunk"
  $apppart      = "${sourcepart}-${version}-${splunkos}-${splunkarch}"
  $oldsource    = "${sourcepart}-${current_version}-${splunkos}-${splunkarch}.${splunkext}"
  $splunksource = "${apppart}.${splunkext}"
  $manifest     = "${apppart}-manifest"

  class { 'splunk::install': type => $type }->
  class { 'splunk::service': }
  if $type != 'search' {
    class { 'splunk::deploy': }
  }

  exec { 'update-inputs':
    command     => "/bin/cat ${local_path}/inputs.d/* > ${local_path}/inputs.conf; \
chown ${splunk_user}:${splunk_group} ${local_path}/inputs.conf",
    refreshonly => true,
    subscribe   => File["${local_path}/inputs.d/000_default"],
    notify      => Service[splunk],
  }

}
