(:~
 : Create new user.
 :
 : @author Christian Grün, BaseX Team, 2014-17
 :)
module namespace dba = 'dba/jobs-users';

import module namespace cons = 'dba/cons' at '../modules/cons.xqm';
import module namespace html = 'dba/html' at '../modules/html.xqm';
import module namespace tmpl = 'dba/tmpl' at '../modules/tmpl.xqm';

(:~ Top category :)
declare variable $dba:CAT := 'jobs-users';

(:~
 : Form for creating a new user.
 : @param  $name   entered name
 : @param  $pw     entered password
 : @param  $perm   chosen permission
 : @param  $error  error string
 :)
declare
  %rest:GET
  %rest:path("/dba/create-user")
  %rest:query-param("name",  "{$name}")
  %rest:query-param("pw",    "{$pw}")
  %rest:query-param("perm",  "{$perm}", "none")
  %rest:query-param("error", "{$error}")
  %output:method("html")
function dba:create(
  $name   as xs:string?,
  $pw     as xs:string?,
  $perm   as xs:string,
  $error  as xs:string?
) as element() {
  cons:check(),
  tmpl:wrap(map { 'top': $dba:CAT, 'error': $error },
    <tr>
      <td>
        <form action="create-user" method="post" autocomplete="off">
          <!--  force chrome not to autocomplete form -->
          <input style="display:none" type="text" name="fake1"/>
          <input style="display:none" type="password" name="fake2"/>
          <h2>{
            html:link('Users', $dba:CAT), ' » ',
            html:button('create', 'Create')
          }</h2>
          <!-- dummy value; prevents reset of options when nothing is selected -->
          <input type="hidden" name="opts" value="x"/>
          <table>
            <tr>
              <td>Name:</td>
              <td>
                <input type="text" name="name" value="{ $name }" id="name"/>
                { html:focus('name') }
                <div class='small'/>
              </td>
            </tr>
            <tr>
              <td>Passsword:</td>
              <td>
                <input type="password" name="pw" value="{ $pw }" id="pw"/>
                <div class='small'/>
              </td>
            </tr>
            <tr>
              <td>Permission:</td>
              <td>
                <select name="perm" size="5">{
                  for $p in $cons:PERMISSIONS
                  return element option { attribute selected { }[$p = $perm], $p }
                }</select>
                <div class='small'/>
              </td>
            </tr>
          </table>
        </form>
      </td>
    </tr>
  )
};

(:~
 : Creates a user.
 : @param  $name  user
 : @param  $pw    password
 : @param  $perm  permission
 : @param  $lang  language
 :)
declare
  %updating
  %rest:POST
  %rest:path("/dba/create-user")
  %rest:query-param("name", "{$name}")
  %rest:query-param("pw",   "{$pw}")
  %rest:query-param("perm", "{$perm}")
function dba:create(
  $name  as xs:string,
  $pw    as xs:string,
  $perm  as xs:string
) {
  cons:check(),
  try {
    if(user:exists($name)) then (
      error((), 'User already exists: ' || $name || '.')
    ) else (
      user:create($name, $pw, $perm)
    ),
    cons:redirect($dba:CAT, map { 'info': 'Created User: ' || $name, 'name': $name })
  } catch * {
    cons:redirect("create-user", map {
      'error': $err:description, 'name': $name, 'pw': $pw, 'perm': $perm
    })
  }
};
