# == Class: mazut::profiles::pacemaker
#
# pacemaker profile class
#
class mazut::profiles::vips() {
   $cluster_master = hiera('mazut::cluster_master')
   $enable_foreman = hiera('mazut::enable_foreman')
   if $::hostname == $cluster_master or $::fqdn == $cluster_master {
     $cluster_members     = hiera('mazut::cluster_members')
     $total               = count($cluster_members)
     if $enable_foreman {
       $search              = "facts.cluster_state = online and facts.role = $::role and facts.region = $::region and last_report > \"30 minutes ago\""
       $hosts               = foreman_search($search)
       $numhosts            = count($hosts)
     }else {
       $numhosts            = "$::cluster_online"
     }
     if "$numhosts" == "$total" {
       class {'mazut::pacemaker::vips':}
     }
   }
}
