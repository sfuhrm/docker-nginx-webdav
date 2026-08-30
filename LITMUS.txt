  # litmus is the WebDAV protocol compliance test suite. It is run
  # against the running container to verify RFC2518/RFC4918 compliance.
  #
  # The image only enables PUT, DELETE, MKCOL, COPY and MOVE (via
  # `dav_methods`) plus PROPFIND and OPTIONS (via `dav_ext_methods`).
  # PROPPATCH, LOCK and UNLOCK are not supported, so the `props` and
  # `locks` suites are excluded from this run.
  TESTS="basic http copymove" litmus http://localhost:8083/ litmus litmus
  shell: /usr/bin/bash -e {0}
-> running `basic':

 0. init.................. 
 0. init.................. pass

 1. begin................. 
 1. begin................. pass

 2. options............... WARNING: server does not claim Class 2 compliance
    ...................... pass (with 1 warning)
    ...................... 
 3. put_get............... pass

 4. put_get_utf8_segment.. 
 4. put_get_utf8_segment.. pass

 5. put_no_parent......... 
 5. put_no_parent......... pass

 6. mkcol_over_plain...... 
 6. mkcol_over_plain...... pass

 7. delete................ 
 7. delete................ pass

 8. delete_null........... 
 8. delete_null........... pass

 9. delete_fragment....... WARNING: DELETE removed collection resource with Request-URI including fragment; unsafe
    ...................... pass (with 1 warning)
    ...................... 
10. mkcol................. pass

11. mkcol_again........... 
11. mkcol_again........... pass

12. delete_coll........... 
12. delete_coll........... pass

13. mkcol_no_parent....... 
13. mkcol_no_parent....... pass

14. mkcol_with_body....... 
14. mkcol_with_body....... pass

15. finish................ 
15. finish................ pass
<- summary for `basic': of 16 tests run: 16 passed, 0 failed. 100.0%
-> 2 warnings were issued.
-> running `http':

 0. init.................. 
 0. init.................. pass

 1. begin................. 
 1. begin................. pass

 2. expect100............. 
 2. expect100............. pass

 3. finish................ 
 3. finish................ pass
<- summary for `http': of 4 tests run: 4 passed, 0 failed. 100.0%
-> running `copymove':

 0. init.................. 
 0. init.................. pass

 1. begin................. 
 1. begin................. pass

 2. copy_init............. 
 2. copy_init............. pass

 3. copy_simple........... WARNING: COPY to new resource should give 201 (RFC2518:S8.8.5)
    ...................... pass (with 1 warning)
    ...................... 
 4. copy_overwrite........ FAIL (COPY overwrites collection: 409 Conflict)

 5. copy_nodestcoll....... WARNING: COPY to non-existant collection '/litmus/nonesuch' gave '500 Internal Server Error' not 409 (RFC2518:S8.8.5)
    ...................... pass (with 1 warning)
    ...................... 
 6. copy_cleanup.......... pass

 7. copy_coll............. 
 7. copy_coll............. pass

 8. copy_shallow.......... 
 8. copy_shallow.......... pass

 9. move.................. WARNING: MOVE to new resource didn't give 201
    ...................... FAIL (MOVE overwrites collection `/litmus/movecoll/' to `/litmus/movedest': 409 Conflict)
    ...................... 
10. move_coll............. FAIL (MOVE collection `/litmus/mvdest2/' over non-collection `/litmus/mvnoncoll' with overwrite: 409 Conflict)

11. move_cleanup.......... 
11. move_cleanup.......... pass

12. finish................ 
12. finish................ pass
<- summary for `copymove': of 13 tests run: 10 passed, 3 failed. 76.9%
-> 3 warnings were issued.
See debug.log for network/debug traces.
