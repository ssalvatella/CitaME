       *>
       *> Medico
       *>
       *> Clase que encapsula el modelo del médico 
       *> en el sistema con todas sus consultas pertinentes.
       *>
       *> Autor: Samuel Salvatella
       *> Ultima modificación: 15/12/2017
       *>
       class-id CitaMe.modelo.Medico.

       working-storage section.

       *> Habilita las variables de SQL
       exec sql 
           include sqlca 
       end-exec.

       01 usuario property type Usuario.
       01 colegiado property string.
       01 comunidad property string.
       01 especialidad property string.
       01 fecha_promocion property string.
       01 inicio_mananas property type TimeSpan.
       01 fin_mananas property type TimeSpan.
       01 inicio_tardes property type TimeSpan.
       01 fin_tardes property type TimeSpan.

       *>
       *> DevuelveMedico
       *>
       *> Devuelve el Médico asociado al ID indicado por parámetro
       *> 
       *> Parámetros:
       *>     idUsuario (int): Id del médico
       *>
       *> Devuelve:
       *>     Médico: objeto con todos los atributos del médico
       *>
       method-id DevuelveMedico.
       local-storage section.
       01 argumentoIdMedico pic S9(9) COMP-4.

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

       *> Atributos de médico
       01 MedicoActual type Medico.
       01 colegiado pic x(25).
       01 comunidad pic x(25).
       01 especialidadMedico pic x(25).

       01 strColegiado string.
       01 strComunidad string.
       01 strEspecialidad string.
       01 fecha_promocion pic X(19).

       01 inicio_mananas pic X(8).
       01 fin_mananas pic X(8).
       01 inicio_tardes pic X(8).
       01 fin_tardes pic X(8).

       procedure division using by value id_medico as binary-short
                          returning medico as type Medico.

           set argumentoIdMedico to id_medico.

           exec sql
               declare medTbl cursor for
                   select * from medicos as m
                   left join usuarios as u on (m.id_usuario_medico = u.id_usuario)
                   where m.id_usuario_medico = :argumentoIdMedico
           end-exec.

           exec sql 
               open medTbl
           end-exec.

           perform until SQLCODE < 0 OR SQLCODE = 100

               exec sql
                   fetch medTbl into
                   :id_usr, :colegiado, :comunidad, :especialidadMedico, :fecha_promocion,
                   :inicio_mananas, :fin_mananas, :inicio_tardes, :fin_tardes, :id_usr,
                   :nombre, :argumentoIdMedico,:nombre_real, :apellidos, :tipo, :fechaRegistro,
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

               set MedicoActual to new Medico()
               set MedicoActual::usuario to UsuarioActual
               set strColegiado to colegiado as type System.String
               set MedicoActual::colegiado to strColegiado::Trim()
               set strComunidad to comunidad as type System.String
               set MedicoActual::comunidad to strComunidad as type System.String
               set strEspecialidad to especialidadMedico as type System.String
               set MedicoActual::especialidad to strEspecialidad::Trim()
               set MedicoActual::fecha_promocion to fecha_promocion
               set MedicoActual::inicio_mananas to type TimeSpan::Parse(inicio_mananas)
               set MedicoActual::fin_mananas to type TimeSpan::Parse(fin_mananas)
               set MedicoActual::inicio_tardes to type TimeSpan::Parse(inicio_tardes)
               set MedicoActual::fin_tardes to type TimeSpan::Parse(fin_tardes)

               set medico to MedicoActual
               goback

           end-perform.

       end method.

       *>
       *> DevuelveMedicosEspecialidad
       *>
       *> Devuelve una lista de médicos que pertenezcan
       *> a la especialidad indicada por parámetro.
       *> 
       *> Parámetros:
       *>     especialidad (str): Especilidad médica
       *>
       *> Devuelve:
       *>     List[Médico]: lista con todos los médicos pertenecientes a la especialidad
       *>
       method-id DevuelveMedicosEspecialidad.
       local-storage section.

       01 argumentoEspecialidad pic x(25).

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

       *> Atributos de médico
       01 MedicoActual type Medico.
       01 colegiado pic x(25).
       01 comunidad pic x(25).
       01 especialidadMedico pic x(25).

       01 strColegiado string.
       01 strComunidad string.
       01 strEspecialidad string.
       01 fecha_promocion pic X(19).

       01 inicio_mananas pic X(8).
       01 fin_mananas pic X(8).
       01 inicio_tardes pic X(8).
       01 fin_tardes pic X(8).


       procedure division using by value especialidad as string
                          returning medicos as type List[type Medico].

           set medicos to new List[type Medico]
           set argumentoEspecialidad to especialidad.
           exec sql
               declare medTbl cursor for
                   select * from medicos as m
                   left join usuarios as u on (m.id_usuario_medico = u.id_usuario)
                   where m.especialidad_medico = :argumentoEspecialidad
           end-exec.

           exec sql 
               open medTbl
           end-exec.

           perform until SQLCODE < 0 OR SQLCODE = 100

               exec sql
                   fetch medTbl into
                   :id_usr, :colegiado, :comunidad, :especialidadMedico, :fecha_promocion,
                   :inicio_mananas, :fin_mananas, :inicio_tardes, :fin_tardes, :id_usr,
                   :nombre, :nombre_real, :apellidos, :tipo, :fechaRegistro,
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

               set MedicoActual to new Medico()
               set MedicoActual::usuario to UsuarioActual
               set strColegiado to colegiado as type System.String
               set MedicoActual::colegiado to strColegiado::Trim()
               set strComunidad to comunidad as type System.String
               set MedicoActual::comunidad to strComunidad as type System.String
               set strEspecialidad to especialidad as type System.String
               set MedicoActual::especialidad to strEspecialidad::Trim()
               set MedicoActual::fecha_promocion to fecha_promocion
               set MedicoActual::inicio_mananas to type TimeSpan::Parse(inicio_mananas)
               set MedicoActual::fin_mananas to type TimeSpan::Parse(fin_mananas)
               set MedicoActual::inicio_tardes to type TimeSpan::Parse(inicio_tardes)
               set MedicoActual::fin_tardes to type TimeSpan::Parse(fin_tardes)

               invoke medicos::Add(MedicoActual)

           end-perform.


       end method.

       *>
       *> HayHueco
       *>
       *> Devuelve si a una determinada fecha y hora hay hueco y no hay ninguna cita
       *> 
       *> Parámetros:
       *>     fecha (DateTime): Fecha a comprobar disponibilidad
       *>     hora (TimeSpan): Hora a comprobar disponibilidad
       *>
       *> Devuelve:
       *>     Boolean: True si hay hueco para una cita
       *>              False si no hay hueco para la cita
       *>
       method-id HayHueco.
       local-storage section.
       01 fechaSQL pic x(10).
       01 horaSQL pic x(8).
       01 limiteHoraSQL pic x(8).
       01 id_cita pic S9(9) COMP-4.
       procedure division using by value fecha as type DateTime
                                         hora as type TimeSpan
                                         returning hayHueco as type Boolean.

           set fechaSQL to fecha::ToString("yyyy-MM-dd").
           set horaSQL to hora::ToString("hh\:mm").
           set limiteHoraSQL to type TimeSpan::Parse(horaSQL)::Add(type TimeSpan::FromSeconds(59))::ToString("hh\:mm\:ss").
           set hayhueco to False.

           exec sql
                  select c.id_cita into :id_cita from citas as c
                   where (fecha_cita = :fechaSQL) and (hora_cita between :horaSQL and :limiteHoraSQL)
           end-exec.


           if SQLCODE >= 100 or SQLCODE < 0
               set hayHueco to True
               goback
           end-if

       end method.

       *>
       *> DevuelveEspecialidades
       *>
       *> Devuelve una lista de todas las especialidades disponibles
       *> 
       *>
       *> Devuelve:
       *>     especialidades List[str]: lista de todas las especialidades existentes
       *>
       method-id DevuelveEspecialidades.
       local-storage section.
       01 especialidad pic x(25).
       01 especialidadString string.
       procedure division returning especialidades as type List[string].

           set especialidades to new List[string].

           exec sql
               declare medTbl cursor for 
               select distinct m.especialidad_medico
                   from medicos as m
           end-exec.

           exec sql 
               open medTbl
           end-exec.

            perform until SQLCODE < 0 OR SQLCODE = 100

               exec sql
                   fetch medTbl into
                   :especialidad
               end-exec

               if SQLCODE < 0 OR SQLCODE = 100
                   goback
               end-if

               set especialidadString to especialidad
               set especialidadString to especialidadString::Trim()
               invoke especialidades::Add(especialidadString)

           end-perform.

       end method.



       end class.
