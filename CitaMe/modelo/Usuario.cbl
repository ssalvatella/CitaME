       *>
       *> Usuario
       *>
       *> Clase que encapsula el modelo del usuario 
       *> del sistema con todas sus consultas pertinentes.
       *>
       *> Autor: Samuel Salvatella
       *> Ultima modificación: 18/12/2017
       *>
       class-id CitaMe.modelo.Usuario.

       working-storage section.

       01 mfsqlmessagetext pic x(355) values "".

       01 TIPO_ADMINISTRADOR static property as "TIPO_ADMINISTRADOR" binary-short value 0.
       01 TIPO_MEDICO static property as "TIPO_MEDICO" binary-short value 1.
       01 TIPO_PACIENTE static property as "TIPO_PACIENTE" binary-short value 2.

       01 id_usu property binary-short.
       01 nombre_usr property type String.
       01 nombre_real_usr property type String.
       01 apellidos_usr property type String.
       01 tipo_usr property type String.
       01 fechaRegistro_usr property type String.
       01 fechaNacimiento_usr property type String.
       01 activo_usr property pic 9.

       *> Habilita las variables de SQL
       exec sql 
           include sqlca 
       end-exec.


       *>
       *> EsValido
       *>
       *> Comprueba que el nombre de usuario y contraseña sean correctos
       *>
       *> Parámetros:
       *>     Nombre (str): Nombre de usuario
       *>     Contrasenia (str): Contraseña del usuario
       *>
       *> Devuelve:
       *>     int: 1 en caso de usuario correcto
       *>          0 en caso de usuario incorrecto
       *>
       method-id EsValido.
       local-storage section.
       01 ParamNombre pic X(16).
	   01 ParamContrasenia pic X(32).

       01 ConsultaNombre pic X(16).
	   01 ConsultaContrasenia pic X(32).

       procedure division using by value Nombre as string,
                                by value Contrasenia as string,
                                returning Correcto as binary-short.

           set ParamNombre to Nombre.
           set ParamContrasenia to Contrasenia.
           move 0 to Correcto.

           *> Consulta SQL
           exec SQL
               select
                      u.nombre_usuario, u.contrasenia_usuario
               into
                   :ConsultaNombre, :ConsultaContrasenia
               from usuarios u
               where (u.nombre_usuario = :ParamNombre and u.contrasenia_usuario = :ParamContrasenia)
           end-exec.

           *> Si se ha devuelto un usuario correcto
           if ConsultaNombre = ParamNombre
               move 1 to Correcto.

           goback.
       end method.

       *>
       *> EstaActivo
       *>
       *> Comprueba que el usuario este activo
       *>
       *> Parámetros:
       *>     Nombre (str): Nombre de usuario
       *>
       *> Devuelve:
       *>     int: 1 en caso de usuario activo
       *>          0 en caso de usuario desactivado
       *>
       method-id EstaActivo.
       local-storage section.

       01 ParamNombre pic X(16).
       01 ConsultaActivo pic 9.

       procedure division using by value Nombre as string,
                                returning Activo as binary-short.

           set ParamNombre to Nombre.
           move 0 to Activo.

           *> Consulta SQL
           exec SQL
               select
                      u.activo_usuario
               into
                   :ConsultaActivo
               from usuarios u
               where (u.nombre_usuario = :ParamNombre)
           end-exec.

           *> Devolvemos si esta activo o no el usuario
           set Activo to ConsultaActivo.
           goback.
       end method.

       *>
       *> DevuelveTipo
       *>
       *> Devuelve el tipo de usuario
       *>
       *> Parámetros:
       *>     Nombre (str): Nombre de usuario
       *>
       *> Devuelve:
       *>     int: 0 para los administradores
       *>          1 para los médicos
       *>          2 para los pacientes
       *>
       method-id DevuelveTipo.
       local-storage section.

       01 ParamNombre pic X(16).
       01 ConsultaTipo pic 9.

       procedure division using by value Nombre as string,
                                returning Tipo as binary-short.

           set ParamNombre to Nombre.
           move 0 to Tipo.

           *> Consulta SQL
           exec SQL
               select
                      u.tipo_usuario
               into
                   :ConsultaTipo
               from usuarios u
               where (u.nombre_usuario = :ParamNombre)
           end-exec.

           *> Devolvemos el tipo de usuario
           set Tipo to ConsultaTipo.
           goback.
       end method.

       *>
       *> UltimosRegistrados
       *>
       *> Devuelve una lista con los últimos usuarios registrados
       *> durante los 7 días anteriores.
       *>
       *> Returns:
       *>     lista[Usuario]: lista de usuarios
       *>
       method-id UltimosRegistrados.
       local-storage section.
       01 Fecha type DateTime.
       01 FechaSQL pic X(20).

       01 id_usr pic S9(9) COMP-4.
       01 nombre pic X(32).
       01 strNombre type String.
       01 nombre_real pic X(45).
       01 strNombreReal type String.
       01 apellidos pic X(80).
       01 strApellidos type String.
       01 tipo pic 9.
       01 fechaRegistro pic X(19).
       01 fechaNacimiento pic X(19).
       01 activo pic 9.

       01 UsuarioActual type Usuario.
       
       procedure division returning Resultados as type List[type Usuario].

           set Resultados to new List[type Usuario].

           set Fecha to type System.DateTime::Now.
           set Fecha to Fecha::AddDays(-7).
           set FechaSQL to Fecha::ToString("yyyy-MM-dd H:mm:ss").
           
           exec sql
               declare usrtbl cursor for 
               select u.id_usuario, u.nombre_usuario, u.nombre_real_usuario,
               u.apellidos_usuario, u.tipo_usuario, u.fechaRegistro_usuario,
               u.fechaNacimiento_usuario, u.activo_usuario
                   from usuarios as u 
                   where u.fechaRegistro_usuario > :FechaSQL
               order by u.fechaRegistro_usuario limit 20
           end-exec.

           exec sql 
               open usrtbl
           end-exec.
           
           perform until SQLCODE < 0 OR SQLCODE = 100

               exec sql
                   fetch usrtbl into
                   :id_usr, :nombre, :nombre_real,
                   :apellidos, :tipo, :fechaRegistro,
                   :fechaNacimiento, :activo
               end-exec

               set UsuarioActual to new Usuario()
               set UsuarioActual::id_usu to id_usr
               set strNombre to nombre as type System.String
               set UsuarioActual::nombre_usr to strNombre::Trim()
               set strNombreReal to nombre_real as type System.String
               set UsuarioActual::nombre_real_usr to strNombreReal::Trim()
               set strApellidos to apellidos as type System.String
               set UsuarioActual::apellidos_usr to strApellidos::Trim()
               evaluate tipo
                   when TIPO_ADMINISTRADOR
                       set UsuarioActual::tipo_usr to "Administrador"
                   when TIPO_MEDICO
                       set UsuarioActual::tipo_usr to "Medico"
                   when TIPO_PACIENTE
                       set UsuarioActual::tipo_usr to "Paciente"
               end-evaluate
               set UsuarioActual::fechaRegistro_usr to fechaRegistro
               set UsuarioActual::fechaNacimiento_usr to fechaNacimiento
               set UsuarioActual::activo_usr to activo

               invoke Resultados::Add(UsuarioActual)

           end-perform.

           exec sql
               close usrtbl
           end-exec.


       end method.

       *>
       *> DevuelveUsuarios
       *>
       *> Devuelve una lista completa con todos los
       *> usuarios registrados en el sistema
       *>
       *> Returns:
       *>     lista[Usuario]: lista de usuarios
       *>
       method-id DevuelveUsuarios.
       local-storage section.

       01 id_usr pic S9(9) COMP-4.
       01 nombre pic X(32).
       01 strNombre type String.
       01 nombre_real pic X(45).
       01 strNombreReal type String.
       01 apellidos pic X(80).
       01 strApellidos type String.
       01 tipo pic 9.
       01 fechaRegistro pic X(19).
       01 fechaNacimiento pic X(19).
       01 activo pic 9.

       01 UsuarioActual type Usuario.
       
       procedure division returning Resultados as type List[type Usuario].

           set Resultados to new List[type Usuario].
           
           exec sql
               declare usrtbl cursor for 
               select u.id_usuario, u.nombre_usuario, u.nombre_real_usuario,
               u.apellidos_usuario, u.tipo_usuario, u.fechaRegistro_usuario,
               u.fechaNacimiento_usuario, u.activo_usuario
                   from usuarios as u
           end-exec.

           exec sql 
               open usrtbl
           end-exec.
           
           perform until SQLCODE < 0 OR SQLCODE = 100

               exec sql
                   fetch usrtbl into
                   :id_usr, :nombre, :nombre_real,
                   :apellidos, :tipo, :fechaRegistro,
                   :fechaNacimiento, :activo
               end-exec

               set UsuarioActual to new Usuario()
               set UsuarioActual::id_usu to id_usr
               set strNombre to nombre as type System.String
               set UsuarioActual::nombre_usr to strNombre::Trim()
               set strNombreReal to nombre_real as type System.String
               set UsuarioActual::nombre_real_usr to strNombreReal::Trim()
               set strApellidos to apellidos as type System.String
               set UsuarioActual::apellidos_usr to strApellidos::Trim()
               display UsuarioActual::apellidos_usr
               evaluate tipo
                   when TIPO_ADMINISTRADOR
                       set UsuarioActual::tipo_usr to "Administrador"
                   when TIPO_MEDICO
                       set UsuarioActual::tipo_usr to "Medico"
                   when TIPO_PACIENTE
                       set UsuarioActual::tipo_usr to "Paciente"
               end-evaluate
               set UsuarioActual::fechaRegistro_usr to fechaRegistro
               set UsuarioActual::fechaNacimiento_usr to fechaNacimiento
               set UsuarioActual::activo_usr to activo

               invoke Resultados::Add(UsuarioActual)

           end-perform.

           exec sql
               close usrtbl
           end-exec.

       end method.

       *>
       *> EditarUsuario
       *>
       *> Edita el usuario con los atributos pasados por parámetro
       *> 
       *> Parámetros:
       *>     idUsuario (int): Id del usuario que va a ser editado
       *>     nombreUsuario (str): Nombre de usuario
       *>     nombreUsuarioReal (str): Nombre real de la persona
       *>     apellidosUsuario (str): Apellidos de la persona
       *>     activoUsuario (int): 1 para usuario activo, 0 para inactivo
       *>
       *> Devuelve:
       *>     int: 1 en caso de ejecución correcta
       *>          0 en caso de error
       *>
       method-id EditarUsuario.
       local-storage section.

       01 nombreUsuarioSQL pic x(45).
       01 nombreRealSQL pic x(45).
       01 apellidosSQL pic x(80).

       procedure division using by value idUsuario as binary-short
                                         nombreUsuarioNuevo as string
                                         nombreRealNuevo as string
                                         apellidosNuevo as string
                                         activoUsuario as binary-short
                                         returning exito as binary-short.

           set nombreUsuarioSQL to nombreUsuarioNuevo.
           set nombreRealSQL to nombreRealNuevo.
           set apellidosSQL to apellidosNuevo.

           exec sql
               update usuarios
               set nombre_usuario = :nombreUsuarioSQL,
                nombre_real_usuario = :nombreRealSQL,
                apellidos_usuario = :apellidosSQL,
                activo_usuario = :activoUsuario
               where id_usuario = :idUsuario
           end-exec.

           exec sql
               commit
           end-exec.
           

           if SQLCODE = 0
               set exito to 1
           else
               set exito to 0
           end-if.

       end method.

       *>
       *> RegistrarUsuario
       *>
       *> Registra el usuario con los atributos pasados por parámetro
       *> 
       *> Parámetros:
       *>     nombreUsuario (str): Nombre de usuario
       *>     nombreUsuarioReal (str): Nombre real de la persona
       *>     apellidosUsuario (str): Apellidos de la persona
       *>     fechaNacimiento (str): Fecha de nacimiento de la persona
       *>     tipoUsuario (int): 0 Admin, 1 Médico, 2 Paciente
       *>
       *> Devuelve:
       *>     Boolean: True en caso de ejecución correcta
       *>              False en caso de error
       *>
       method-id RegistrarUsuario.
       local-storage section.
       01 nombreUsuarioSQL pic x(45).
       01 contraseniaSQL pic x(32).
       01 nombreRealSQL pic x(45).
       01 apellidosSQL pic x(80).
       01 fechaNacimientoSQL pic x(10).
       01 tipoUsuarioSQL pic 9.
       01 fechaNacimientoDateTime type DateTime.

       procedure division using by value nombreUsuario as string
                                         contrasenia as string
                                         nombreReal as string
                                         apellidos as string
                                         fechaNacimiento as string
                                         tipoUsuario as string
                                         returning exito as type Boolean.

           *> Hay que usar cadenas COBOL para el SQL
           set nombreUsuarioSQL to nombreUsuario.
           set contraseniaSQL to contrasenia.
           set nombreRealSQL to nombreReal.
           set apellidosSQL to apellidos.
           evaluate tipoUsuario
               when "Paciente"
                   set tipoUsuarioSQL to TIPO_PACIENTE
               when "Medico"
                   set tipoUsuarioSQL to TIPO_MEDICO
               when "Administrador"
                   set tipoUsuarioSQL to TIPO_ADMINISTRADOR
           end-evaluate

           set fechaNacimientoDateTime to type DateTime::ParseExact(fechaNacimiento, "dd/MM/yyyy",  type System.Globalization.CultureInfo::InvariantCulture).
           set fechaNacimientoSQL to fechaNacimientoDateTime::ToString("yyyy-MM-dd").
           exec sql
             insert into usuarios (nombre_usuario, contrasenia_usuario, nombre_real_usuario, apellidos_usuario, tipo_usuario, fechaNacimiento_usuario)
             values (:nombreUsuarioSQL, :contraseniaSQL, :nombreRealSQL, :apellidosSQL, :tipoUsuarioSQL, :fechaNacimientoSQL)
           end-exec.

           if SQLCODE < 0
               set exito to false
           else
               set exito to True
           end-if

           exec sql
               commit
           end-exec.
                                         
       end method.

       *>
       *> RegistrarPaciente
       *>
       *> Registra el paciente con los atributos pasados por parámetro
       *> 
       *> Parámetros:
       *>     idUsuario (int): Id del usuario referente al paciente
       *>     seguridadSocial (str): Nº de seguridad social
       *>     dni (str): Nº de dni
       *>     comunidad (str): Comunidad autónoma del paciente
       *>     sexo (str): Sexo del paciente
       *>     genero (str): Genero del paciente
       *>
       *> Devuelve:
       *>     Boolean: True en caso de ejecución correcta
       *>              False en caso de error
       *>
       method-id RegistrarPaciente.
       local-storage section.
       01 idUsuarioSQL pic S9(9) COMP-4.
       01 seguridadSocialSQL pic x(12).
       01 dniSQL pic x(10).
       01 comunidadSQL pic x(25).
       01 sexoSQL pic x(25).
       01 generoSQL pic x(25).
       procedure division using by value idUsuario as binary-short
                                         seguridadSocial as string
                                         dni as string
                                         comunidad as string
                                         sexo as string
                                         genero as string
                                         returning exito as type Boolean.

           set idUsuario to idUsuarioSQL.
           set seguridadSocialSQL to seguridadSocial.
           set dniSQL to dni.
           set comunidadSQL to comunidad.
           set sexoSQL to sexo.
           set generoSQL to genero.

           exec sql
             insert into pacientes values
             (:idUsuario, :seguridadSocialSQL, :dniSQL, :comunidadSQL, :sexoSQL, :generoSQL)
           end-exec.

           if SQLCODE < 0
               set exito to false
           else
               set exito to True
           end-if

           exec sql
               commit
           end-exec.

       end method.

       *>
       *> RegistrarMedico
       *>
       *> Registra el médico con los atributos pasados por parámetro
       *> 
       *> Parámetros:
       *>     idUsuario (int): Id del usuario referente al médico
       *>     colegiado (str): Nº de seguridad social
       *>     especialidad (str): Nº de dni
       *>     comunidad (str): Comunidad autónoma del paciente
       *>     fechaPromocion (str): Sexo del paciente
       *>     inicioManianas (str): Inicio del horario de mañanas (ejem: 08:00)
       *>     finManianas (str): Fin del horario de mañanas (ejem: 12:30)
       *>     inicioTardes (str): Inicio del horario de tardes (ejem: 15:00)
       *>     finTardes (str): Fin del horario de tardes (ejem: 20:00)
       *>
       *> Devuelve:
       *>     Boolean: True en caso de ejecución correcta
       *>              False en caso de error
       *>
       method-id RegistrarMedico.
       local-storage section.
       01 idUsuarioSQL pic S9(9) COMP-4.
       01 colegiadoSQL pic x(25).
       01 comunidadSQL pic x(25).
       01 especialidadSQL pic x(25).
       01 fechaPromocionSQL pic x(10).
       01 inicioManianasSQL pic x(25).
       01 finManianasSQL pic x(25).
       01 inicioTardesSQL pic x(25).
       01 finTardesSQL pic x(25).
       01 fechaPromocionDateTime type DateTime.
       procedure division using by value idUsuario as binary-short
                                         colegiado as string
                                         comunidad as string
                                         especialidad as string
                                         fechaPromocion as string
                                         inicioManianas as string
                                         finManianas as string
                                         inicioTardes as string
                                         finTardes as string
                                         returning exito as type Boolean.

           set idUsuario to idUsuarioSQL.
           set colegiadoSQL to colegiado.
           set comunidadSQL to comunidad.
           set especialidadSQL to especialidad.
           set inicioManianasSQL to inicioManianas.
           set finManianasSQL to finManianas.
           set inicioTardesSQL to inicioTardes.
           set finTardesSQL to finTardes.

           set fechaPromocionDateTime to type DateTime::ParseExact(fechaPromocion, "dd/MM/yyyy",  type System.Globalization.CultureInfo::InvariantCulture).
           set fechaPromocionSQL to fechaPromocionDateTime::ToString("yyyy-MM-dd").


           exec sql
             insert into medicos values
             (:idUsuario, :colegiadoSQL, :comunidadSQL, :especialidadSQL, :fechaPromocionSQL, :inicioManianasSQL, :finManianasSQL, :inicioTardesSQL, :finTardesSQL)
           end-exec.

           if SQLCODE < 0
               set exito to false
           else
               set exito to True
           end-if

           exec sql
               commit
           end-exec.

       end method.


       *>
       *> NombreUsuarioExiste
       *>
       *> Devuelve True si el nombre de usuario pasado por parámetro
       *> ya esta registrado y False en caso contrario.
       *> 
       *> Parámetros:
       *>     nombreUsuario (str): Nombre de usuario a comprobar
       *>
       *> Devuelve:
       *>     Boolean: True en caso de que ya este registrado
       *>              False en caso contrario
       *>
       method-id NombreUsuarioExiste.
       local-storage section.
       01 nombreUsuarioSQL pic x(45).
       procedure division using by value nombreUsuario as string
                                   returning existe as type Boolean.
           set nombreUsuarioSQL to nombreUsuario.

           exec sql 
               declare existeUsuario cursor for
               select nombre_usuario from usuarios where nombre_usuario = :nombreUsuarioSQL
           end-exec.

           exec sql
               open existeUsuario
           end-exec.

           exec sql
               fetch existeUsuario into
               :nombreUsuarioSQL
           end-exec.

           if SQLCODE >= 100 or SQLCODE < 0
               set existe to false
               goback
           end-if

           set existe to True.
       end method.

       *>
       *> DevuelveIdUsuario
       *>
       *> Dado un nombre de usuario devuelve el ID asociado a ese usuario.
       *> 
       *> Parámetros:
       *>     nombreUsuario (str): Nombre de usuario a devolver ID
       *>
       *> Devuelve:
       *>     Int: Id del usuario con el nombre indicado
       *>
       method-id DevuelveIdUsuario.
       local-storage section.
       01 nombreUsuarioSQL pic x(45).
       01 idUsuarioSQL pic S9(9) COMP-4.
       procedure division using by value nombreUsuario as string
                                   returning idUsuario as binary-short.
           set nombreUsuarioSQL to nombreUsuario::Trim().

           exec sql 
               declare existeUsuario cursor for
               select id_usuario from usuarios where nombre_usuario = :nombreUsuarioSQL
           end-exec.

           exec sql
               open existeUsuario
           end-exec.

           exec sql
               fetch existeUsuario into
               :idUsuarioSQL
           end-exec.

           set idUsuario to idUsuarioSQL.
       end method.


       end class.