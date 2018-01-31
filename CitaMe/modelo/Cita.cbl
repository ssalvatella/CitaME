       *>
       *> Cita
       *>
       *> Clase que encapsula el modelo de la cita 
       *> en el sistema con todas sus consultas pertinentes
       *> para su registro.
       *>
       *> Autor: Samuel Salvatella
       *> Ultima modificación: 15/12/2017
       *>
       class-id CitaMe.modelo.Cita.

       working-storage section.

       01 modeloMedico type Medico.
       01 modeloPaciente type CitaMe.modelo.Paciente.

       01 medico property type Medico.
       01 paciente property type Paciente.
       01 id_cita property pic S9(9) COMP-4.
       01 medico_cita property pic S9(9) COMP-4.
       01 paciente_cita property pic S9(9) COMP-4.
       01 motivo_cita property type String.
       01 fecha_cita property type DateTime.
       01 hora_cita property type TimeSpan.
       01 cancelada_cita property binary-short.
       01 encuesta_cita property pic S9(9) COMP-4.
       01 diagnostico_cita property string.


       *> Habilita las variables de SQL
       exec sql 
           include sqlca 
       end-exec.


       method-id NEW.
       local-storage section.
       procedure division.
           set modeloMedico to new Medico().
           set modeloPaciente to new Paciente().
           goback.
       end method.

       *>
       *> Asignar
       *>
       *> Dados los datos para una cita, busca hueco entre las agendas de
       *> los médicos y asigna la cita a un hueco disponible.
       *> 
       *> Parámetros:
       *>     motivo (str): Motivo de la cita
       *>     especialidad (str): Especialidad para la cita
       *>     idUsuario (int): Id del médico
       *>     idUsuario (int): Id del médico
       *>
       *> Devuelve:
       *>     Médico: objeto con todos los atributos del médico
       *>
       method-id Asignar.
       local-storage section.
       01 especialistas List[type Medico].
       01 horaEncontrada type Boolean.
       01 resultados list[object].
       01 fecha type DateTime.
       01 horaCita type TimeSpan.
       01 idMedico binary-short.
       procedure division using by value motivo as string
                                         especialidad as string
                                         horario as string
                                         emergencia as binary-short
                                         returning cita as type Cita.

           set especialistas to modeloMedico::DevuelveMedicosEspecialidad(especialidad).
           if especialistas::Count = 0
               goback
           end-if.
           set fecha to type System.DateTime::Now.
           set horaEncontrada to false.
           perform until horaEncontrada
               set resultados to BuscarHueco(especialistas, fecha, horario)
               if not resultados = null
                   set horaEncontrada to True
               else
                   set fecha to fecha::AddDays(1)
               end-if
           end-perform.
           
           set horaCita to resultados[0] as type TimeSpan.
           set idMedico to resultados[1] as binary-short.
           set cita to RegistrarCita(idMedico, type CitaMe.vista.Login::idUsuario, motivo, fecha, horaCita)

       end method.

       *>
       *> BuscarHueco
       *>
       *> Dada una lista de médicos, una fecha y un horario (mañanas/tardes),
       *> busca un hueco en las agendas de cada médico y devuelve la hora y el
       *> ID del médico con la agenda libre.
       *> 
       *> Parámetros:
       *>     especialistas (List[Medico]): Motivo de la cita
       *>     fecha (DateTime): Día en el que buscar hueco
       *>     horario (str): Horario en el que buscar hueco (mañanas/tardes)
       *>
       *> Devuelve:
       *>     List[object]: lista con 2 objetos, el primero la hora en la
       *>     que se ha encontrado hueco y el segundo el ID del médico
       *>
       method-id BuscarHueco.
       local-storage section.
       01 hoy type DateTime.
       01 hora type TimeSpan.
       01 sumaHoras type TimeSpan.
       01 sumaMinutos type TimeSpan.
       01 minutosParaDiez pic 9.
       01 minutosQueSumar pic 9.
       01 limiteHora type TimeSpan.
       procedure division using by value especialistas as list[type Medico]
                                         fecha as type DateTime
                                         horario as string
                                         returning resultados as list[object].
           if horario::Equals("Mananas")
               set limiteHora to type TimeSpan::Parse("14:00:00")
           else
               set limiteHora to type TimeSpan::Parse("22:00:00")
           end-if

           set hoy to type System.DateTime::Now.

           *> Si la fecha es la de hoy
           if fecha::DayOfYear = hoy::DayOfYear
               set hora to hoy::TimeOfDay
               set sumaHoras to type TimeSpan::FromHours(2)
               set sumaMinutos to type TimeSpan::FromMinutes(10)
               set hora to hora::Add(sumaHoras)
               set hora to hora::Add(sumaMinutos)
               set minutosParaDiez to function mod(hora::Minutes, 10)
               subtract minutosParaDiez from 10 giving minutosQueSumar
               set sumaMinutos to type TimeSpan::FromMinutes(minutosQueSumar)
               set hora to hora::Add(sumaMinutos)
           else 
               if horario::Equals("Tardes")
                   set hora to especialistas::First()::inicio_tardes
               else
                   set hora to especialistas::First()::inicio_mananas
               end-if

               set minutosParaDiez to function mod(hora::Minutes, 10)
               subtract minutosParaDiez from 10 giving minutosQueSumar
               set sumaMinutos to type TimeSpan::FromMinutes(minutosQueSumar)
               set hora to hora::Add(sumaMinutos)

           end-if

           set sumaMinutos to type TimeSpan::FromMinutes(10)
           perform until hora::Hours = limiteHora::Hours and hora::Minutes = limiteHora::Minutes
               perform varying especialista as type CitaMe.modelo.Medico through especialistas
                   evaluate horario
                       when "Mananas"
                           *> Hora entre horario de mañanas
                           if type TimeSpan::Compare(hora, especialista::inicio_mananas) = 1
                               and type TimeSpan::Compare(hora, especialista::fin_mananas) = -1
                               if especialista::HayHueco(fecha, hora)
                                   set resultados to new List[object]
                                   invoke resultados::Add(hora)
                                   invoke resultados::Add(especialista::usuario::id_usu)
                                   goback
                               end-if
                           end-if
                       when "Tardes"
                           *> Hora entre horario de tardes
                           if type TimeSpan::Compare(hora, especialista::inicio_tardes) = 1
                               and type TimeSpan::Compare(hora, especialista::fin_tardes) = -1
                               if especialista::HayHueco(fecha, hora)
                                   set resultados to new List[object]
                                   invoke resultados::Add(hora)
                                   invoke resultados::Add(especialista::usuario::id_usu)
                                   goback
                               end-if
                           end-if
                      
                       when "Indiferente"
                           *> Hora entre horario de mañanas o de tardes
                           if (type TimeSpan::Compare(hora, especialista::inicio_mananas) = 1
                               and type TimeSpan::Compare(hora, especialista::fin_mananas) = -1) or
                               (type TimeSpan::Compare(hora, especialista::inicio_tardes) = 1
                               and type TimeSpan::Compare(hora, especialista::fin_tardes) = -1)
                               if especialista::HayHueco(fecha, hora)
                                   set resultados to new List[object]
                                   invoke resultados::Add(hora)
                                   invoke resultados::Add(especialista::usuario::id_usu)
                                   goback
                               end-if

                           end-if

                   end-evaluate
               end-perform
               set hora to hora::Add(sumaMinutos)
           end-perform.



       end method.

       *>
       *> RegistrarCita
       *>
       *> Dados los atributos de una cita, la registra en la base de datos.
       *> 
       *> Parámetros:
       *>     medico (int): ID del médico de la cita
       *>     paciente (int): ID del paciente de la cita
       *>     motivo (str): Motivo de la cita
       *>     fecha (DateTime): Fecha de la cita
       *>     hora (TimeSpan): Hora de la cita
       *>
       *> Devuelve:
       *>     cita (Cita): objeto cita registrado
       *>
       method-id RegistrarCita.
       local-storage section.
       01 motivoSQL pic x(1000).
       01 fechaSQL pic x(10).
       01 horaSQL pic x(8).
       procedure division using medico as binary-short 
                                paciente as binary-short
                                motivo as string
                                fecha as type DateTime
                                hora as type TimeSpan
                                returning cita as type Cita.

           set motivoSQL to motivo.
           set fechaSQL to fecha::ToString("yyyy-MM-dd").
           set horaSQL to hora::ToString("hh\:mm\:ss").

           exec sql
             insert into citas (medico_cita, paciente_cita, motivo_cita, fecha_cita, hora_cita)
             values (:medico, :paciente, :motivoSQL, :fechaSQL, :horaSQL)
           end-exec.

           if SQLCODE < 0
               set cita to null
           else
               set cita to new Cita()
               set cita::medico_cita to medico
               set cita::paciente_cita to paciente
               set cita::motivo_cita to motivo
               set cita::fecha_cita to fecha
               set cita::hora_cita to hora
           end-if

           exec sql
               commit
           end-exec.

       end method.

       *>
       *> DevuelveCitasPaciente
       *>
       *> Devuelve todas o las próximas citas del paciente indicado.
       *> 
       *> Parámetros:
       *>     paciente (int): ID del paciente
       *>     proxima (Boolean): True si solo se quieren las próximas citas
       *>                        False si se quieren todas las citas habidas
       *>
       *> Devuelve:
       *>     citas (List[Cita]): lista de citas
       *>
       method-id DevuelveCitasPaciente.
       local-storage section.
       01 argumentoIdPaciente pic S9(9) COMP-4.

       01 citaActual type Cita.
       01 id_cita pic S9(9) COMP-4.
       01 id_medico pic S9(9) COMP-4.
       01 paciente pic S9(9) COMP-4.
       01 cancelada pic 9.
       01 id_encuesta pic S9(9) COMP-4.
       01 motivo pic x(1000).
       01 motivoStr string.
       01 diagnostico pic x(5000).
       01 diagnosticoStr string.
       01 fechaSQL pic x(10).
       01 horaSQL pic x(8).
       01 hoySQL pic x(10).
       01 fecha type DateTime.

       procedure division using by value id_paciente as binary-short
                                         proximas as type Boolean
                                   returning citas as List[type Cita].

           set citas to new List[type Cita]().
           set argumentoIdPaciente to id_paciente.

           set hoySQL to type DateTime::Now::ToString('yyyy-MM-dd').

           if proximas
               exec sql
                   declare citaTblProx cursor for
                       select * from citas as c
                       where c.paciente_cita = :argumentoIdPaciente and c.fecha_cita >= :hoySQL
               end-exec
               exec sql 
                   open citaTblProx
               end-exec

           else
               exec sql
                   declare citaTbl cursor for
                       select * from citas as c
                       where c.paciente_cita = :argumentoIdPaciente
               end-exec
               exec sql 
                   open citaTbl
               end-exec
           end-if

           perform until SQLCODE = 100

               if proximas
                   exec sql
                       fetch citaTblProx into
                       :id_cita, :id_medico, :paciente, :motivo, :fechaSQL,
                       :horaSQL, :cancelada, :id_encuesta, :diagnostico
                   end-exec
               else
                   exec sql
                       fetch citaTbl into
                       :id_cita, :id_medico, :paciente, :motivo, :fechaSQL,
                       :horaSQL, :cancelada, :id_encuesta, :diagnostico
                   end-exec
               end-if

               if SQLCODE = 100
                   goback
               end-if

               set citaActual to new Cita()
               set citaActual::id_cita to id_cita
               set citaActual::medico_cita to id_medico
               set citaActual::paciente_cita to paciente
               set citaActual::cancelada_cita to cancelada
               set citaActual::encuesta_cita to id_encuesta
               set motivoStr to motivo as string
               set citaActual::motivo_cita to motivoStr::Trim()
               set diagnosticoStr to diagnostico as string
               set fecha to type DateTime::ParseExact(fechaSQL, "yyyy-MM-dd",  type System.Globalization.CultureInfo::InvariantCulture)
               set citaActual::fecha_cita to fecha
               set citaActual::hora_cita to type TimeSpan::Parse(horaSQL)
               set citaActual::medico to modeloMedico::DevuelveMedico(id_medico)
               set citaActual::paciente to modeloPaciente::DevuelvePaciente(id_paciente)

               invoke citas::Add(citaActual)

           end-perform.

       end method.

       *>
       *> DevuelveCitasPacienteSinEncuesta
       *>
       *> Devuelve la lista de citas ocurridas en las que el paciente
       *> no haya completado las encuestas
       *> 
       *> Parámetros:
       *>     paciente (int): ID del paciente
       *>
       *> Devuelve:
       *>     citas (List[Cita]): lista de citas
       *>
       method-id DevuelveCitasPacienteSinEncuesta.
       local-storage section.
       01 argumentoIdPaciente pic S9(9) COMP-4.

       01 citaActual type Cita.
       01 id_cita pic S9(9) COMP-4.
       01 id_medico pic S9(9) COMP-4.
       01 paciente pic S9(9) COMP-4.
       01 cancelada pic 9.
       01 id_encuesta pic S9(9) COMP-4.
       01 motivo pic x(1000).
       01 motivoStr string.
       01 diagnostico pic x(5000).
       01 diagnosticoStr string.
       01 fechaSQL pic x(10).
       01 horaSQL pic x(8).
       01 hoySQL pic x(10).
       01 fecha type DateTime.

       procedure division using by value id_paciente as binary-short
                                   returning citas as List[type Cita].

           set citas to new List[type Cita]().
           set argumentoIdPaciente to id_paciente.

           set hoySQL to type DateTime::Now::ToString('yyyy-MM-dd').

           exec sql
               declare citaTbl cursor for
                   select * from citas as c
                   where c.paciente_cita = :argumentoIdPaciente and c.diagnostico_cita is not null and c.encuesta_cita is null
           end-exec
           exec sql 
               open citaTbl
           end-exec

           perform until SQLCODE = 100

               exec sql
                   fetch citaTbl into
                   :id_cita, :id_medico, :paciente, :motivo, :fechaSQL,
                   :horaSQL, :cancelada, :id_encuesta, :diagnostico
               end-exec

               if SQLCODE = 100
                   goback
               end-if

               set citaActual to new Cita()
               set citaActual::id_cita to id_cita
               set citaActual::medico_cita to id_medico
               set citaActual::paciente_cita to paciente
               set citaActual::cancelada_cita to cancelada
               set citaActual::encuesta_cita to id_encuesta
               set motivoStr to motivo as string
               set citaActual::motivo_cita to motivoStr::Trim()
               set diagnosticoStr to diagnostico as string
               set fecha to type DateTime::ParseExact(fechaSQL, "yyyy-MM-dd",  type System.Globalization.CultureInfo::InvariantCulture)
               set citaActual::fecha_cita to fecha
               set citaActual::hora_cita to type TimeSpan::Parse(horaSQL)
               set citaActual::medico to modeloMedico::DevuelveMedico(id_medico)
               set citaActual::paciente to modeloPaciente::DevuelvePaciente(id_paciente)

               invoke citas::Add(citaActual)

           end-perform.

       end method.

       *>
       *> DevuelveCitasMedico
       *>
       *> Devuelve todas o las próximas citas del médico indicado.
       *> 
       *> Parámetros:
       *>     médico (int): ID del médico
       *>     proxima (Boolean): True si solo se quieren las próximas citas
       *>                        False si se quieren todas las citas habidas
       *>
       *> Devuelve:
       *>     citas (List[Cita]): lista de citas
       *>
       method-id DevuelveCitasMedico.
       local-storage section.
       01 argumentoIdMedico pic S9(9) COMP-4.

       01 citaActual type Cita.
       01 id_cita pic S9(9) COMP-4.
       01 paciente pic S9(9) COMP-4.
       01 cancelada pic S9(9) COMP-4.
       01 id_encuesta pic S9(9) COMP-4.
       01 motivo pic x(1000).
       01 motivoStr string.
       01 diagnostico pic x(5000).
       01 diagnosticoStr string.
       01 fechaSQL pic x(10).
       01 horaSQL pic x(8).
       01 hoySQL pic x(10).
       01 fecha type DateTime.

       procedure division using by value id_medico as binary-short
                                         proximas as type Boolean
                                   returning citas as List[type Cita].

           set citas to new List[type Cita]().
           set argumentoIdMedico to id_medico.

           set hoySQL to type DateTime::Now::ToString('yyyy-MM-dd').

           if proximas
               exec sql
                   declare citaTblProx cursor for
                       select * from citas as c
                       where c.medico_cita = :argumentoIdMedico and c.fecha_cita >= :hoySQL and c.cancelada_cita = 0 and c.diagnostico_cita is null
               end-exec
               exec sql 
                   open citaTblProx
               end-exec

           else
               exec sql
                   declare citaTbl cursor for
                       select * from citas as c
                       where c.medico_cita = :argumentoIdMedico and c.cancelada_cita = 0 order by c.fecha_cita desc
               end-exec
               exec sql 
                   open citaTbl
               end-exec
           end-if

           perform until SQLCODE = 100

               if proximas
                   exec sql
                       fetch citaTblProx into
                       :id_cita, :id_medico, :paciente, :motivo, :fechaSQL,
                       :horaSQL, :cancelada, :id_encuesta, :diagnostico
                   end-exec
               else
                   exec sql
                       fetch citaTbl into
                       :id_cita, :id_medico, :paciente, :motivo, :fechaSQL,
                       :horaSQL, :cancelada, :id_encuesta, :diagnostico
                   end-exec
               end-if

               if SQLCODE = 100
                   goback
               end-if

               set citaActual to new Cita()
               set citaActual::id_cita to id_cita
               set citaActual::medico_cita to id_medico
               set citaActual::paciente_cita to paciente
               set citaActual::cancelada_cita to cancelada
               set citaActual::encuesta_cita to id_encuesta
               set motivoStr to motivo as string
               set citaActual::motivo_cita to motivoStr::Trim()
               set diagnosticoStr to diagnostico as string
               set fecha to type DateTime::ParseExact(fechaSQL, "yyyy-MM-dd",  type System.Globalization.CultureInfo::InvariantCulture)
               set citaActual::fecha_cita to fecha
               set citaActual::hora_cita to type TimeSpan::Parse(horaSQL)
               set citaActual::medico to modeloMedico::DevuelveMedico(id_medico)
               set citaActual::paciente to modeloPaciente::DevuelvePaciente(paciente)

               invoke citas::Add(citaActual)

           end-perform.

       end method.

       *>
       *> RegistrarDiagnostico
       *>
       *> Registra el diagnóstico del médico en la cita indicada por parámetro.
       *> 
       *> Parámetros:
       *>     cita (int): ID de la cita a la que se va a añadir el diagnóstico
       *>     diagnostico (str): Cadena con el diagnóstico del médico
       *>
       *> Devuelve:
       *>     exito (Boolean): True en caso de ejecución correcta
       *>                      False en caso de error
       *>
       method-id RegistrarDiagnostico.
       01 id_cita pic S9(9) COMP-4.
       01 diagnostico_sql pic x(5000).
       procedure division using argumentoCita as binary-long diagnostico as string
                               returning exito as type Boolean.

           set id_cita to argumentoCita.
           set diagnostico_sql to diagnostico.
            exec sql
               update citas
               set diagnostico_cita = :diagnostico_sql
               where id_cita = :id_cita
           end-exec.

           exec sql
               commit
           end-exec.
           

           if SQLCODE = 0
               set exito to True
           else
               set exito to False
           end-if.


       end method.

       *>
       *> CancelarCita
       *>
       *> Cancela la cita indicada por parámetro.
       *> 
       *> Parámetros:
       *>     cita (int): ID de la cita que se desea cancelar
       *>
       *> Devuelve:
       *>     exito (Boolean): True en caso de ejecución correcta
       *>                      False en caso de error
       *>
       method-id CancelarCita.
       01 id_cita pic S9(9) COMP-4.
       procedure division using argumentoCita as binary-long
                               returning exito as type Boolean.

           set id_cita to argumentoCita.

            exec sql
               update citas
               set cancelada_cita = 1
               where id_cita = :id_cita
           end-exec.

           exec sql
               commit
           end-exec.
           

           if SQLCODE = 0
               set exito to True
           else
               set exito to False
           end-if.


       end method.


       end class.
