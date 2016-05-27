# controller 
class mazut::roles::hacontroller () {
  stage { '1': }->
  stage { '2': }->
  stage { '3': }->
  stage { '4': }

  class  { 'mazut::profiles::pacemaker': stage => 1 }
  class  { 'mazut::profiles::vips':      stage => 2 }
  class  { 'mazut::profiles::haproxy':   stage => 3 }
  class  { 'mazut::profiles::rabbitmq':  stage => 3 }
  class  { 'mazut::profiles::db':        stage => 3 }
  class  { 'mazut::profiles::mongodb':   stage => 3 }
  class  { 'mazut::profiles::api':       stage => 3 }
  class  { 'mazut::profiles::networker': stage => 4 }
}
