       *>
       *> Paciente
       *>
       *> Clase que encapsula el modelo del paciente 
       *> en el sistema con todas sus consultas pertinentes.
       *>
       *> Autor: Samuel Salvatella
       *> Ultima modificación: 18/12/2017
       *>
       class-id CitaMe.modelo.Paciente.

       working-storage section.

       *> Habilita las variables de SQL
       exec sql 
           include sqlca 
       end-exec.

       01 usuario property type Usuario.
       01 seguridad_social property string.
       01 dni property string.
       01 comunidad property string.
       01 sexo property string.
       01 genero property string.

       *>
       *> DevuelvePaciente
       *>
       *> Devuelve el Paciente asociado al ID indicado por parámetro
       *> 
       *> Parámetros:
       *>     idUsuario (int): Id del paciente
       *>
       *> Devuelve:
       *>     Paciente: objeto con todos los atributos del paciente
       *>
       method-id DevuelvePaciente.
       local-storage section.
       01 argumentoIdPaciente pic S9(9) COMP-4.

       *> Atributos de usuario
       01 UsuarioActual type Usuario.
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

       *> Atributos de paciente
       01 PacienteActual type Paciente.
       01 seguridad_social_paciente pic x(12).
       01 comunidad_paciente pic x(25).
       01 dni_paciente pic x(10).
       01 sexo_paciente pic x(25).
       01 genero_paciente pic x(25).

       01 strSeguridadSocial string.
       01 strComunidad string.
       01 strDni string.
       01 strSexo string.
       01 strGenero string.

       procedure division using by value id_paciente as binary-short
                          returning paciente as type Paciente.

           set argumentoIdPaciente to id_paciente.

           exec sql
               declare pacTbl cursor for
                   select * from pacientes as p
                   left join usuarios as u on (p.id_usuario_paciente = u.id_usuario)
                   where p.id_usuario_paciente = :argumentoIdPaciente
           end-exec.

           exec sql 
               open pacTbl
           end-exec.

           perform until SQLCODE < 0 OR SQLCODE = 100

               exec sql
                   fetch pacTbl into
                   :id_usr, :seguridad_social_paciente, :dni_paciente, :comunidad_paciente, :sexo_paciente, :genero_paciente, :id_usr,
                   :nombre, :argumentoIdPaciente,:nombre_real, :apellidos, :tipo, :fechaRegistro,
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
                   when type CitaMe.modelo.Usuario::TIPO_ADMINISTRADOR
                       set UsuarioActual::tipo_usr to "Administrador"
                   when type CitaMe.modelo.Usuario::TIPO_MEDICO
                       set UsuarioActual::tipo_usr to "Medico"
                   when type CitaMe.modelo.Usuario::TIPO_PACIENTE
                       set UsuarioActual::tipo_usr to "Paciente"
               end-evaluate
               set UsuarioActual::fechaRegistro_usr to fechaRegistro
               set UsuarioActual::fechaNacimiento_usr to fechaNacimiento
               set UsuarioActual::activo_usr to activo

               set PacienteActual to new Paciente()
               set PacienteActual::usuario to UsuarioActual
               set strSeguridadSocial to seguridad_social_paciente as type System.String
               set PacienteActual::seguridad_social to strSeguridadSocial::Trim()
               set strComunidad to comunidad_paciente as type System.String
               set PacienteActual::comunidad to strComunidad as type System.String
               set strDni to dni_paciente as type System.String
               set PacienteActual::dni to strDni::Trim()
               set PacienteActual::comunidad to strComunidad as type System.String
               set strSexo to sexo_paciente as type System.String
               set PacienteActual::sexo to strSexo::Trim()
               set strGenero to genero_paciente as type System.String
               set PacienteActual::genero to strGenero::Trim()

               set paciente to PacienteActual
               goback

           end-perform.

       end method.

       end class.
