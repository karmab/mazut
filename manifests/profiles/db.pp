# == Class: mazut::profiles::db
#
# db profile class
#
class mazut::profiles::db (){
 $enable_galera  = hiera('mazut::enable_galera')
 $enable_foreman    = hiera('mazut::enable_foreman')

 if $enable_galera {
   $galera_master_name  = hiera('mazut::galera_master_name')
   class {'mazut::db::galera':}
   if $::hostname == $galera_master_name or $::fqdn == $galera_master_name {
     if $::galera_state == 'running' {
       class {'mazut::db::services':}
     }
     $galera_internal_ips = hiera('mazut::galera_internal_ips')
     $total               = count($galera_internal_ips)
     if $enable_foreman {
       $search              = "facts.galera_state = ready and facts.role = $::role and facts.region = $::region and last_report > \"30 minutes ago\""
       $hosts               = foreman_search($search)
       $numhosts            = count($hosts)
     } else {
       $numhosts            = $::cluster_online
     }
     if "$numhosts" == "$total" {
       class {'mazut::pacemaker::galera':
         require => Class['mazut::pacemaker::core'],
      }
     }
   }
 }else {
   class {'mazut::db::single':}
 }
}
