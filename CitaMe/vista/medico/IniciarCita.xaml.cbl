       *>
       *> IniciarCita
       *>
       *> Clase de control de la vista que
       *> muestra una cita en la que completar el
       *> diagnóstico.
       *>
       *> Autor: Samuel Salvatella
       *> Ultima modificación: 05/01/2018
       *>
       class-id CitaMe.vista.medico.IniciarCita is partial
                 inherits type System.Windows.Controls.Page.

       working-storage section.

       01 vtnPrincipal type CitaMe.vista.VentanaPrincipal.
       01 cita property static type CitaMe.modelo.Cita.
       01 modeloCita type CitaMe.modelo.Cita.


       method-id NEW.
       procedure division.
           invoke self::InitializeComponent().
           *> Guardamos la referencia a la ventana principal
           set vtnPrincipal to type CitaMe.vista.VentanaPrincipal::DevuelveInstancia().
           *> Cargamos el modelo de cita para usuarlo
           set modeloCita to new CitaMe.modelo.Cita().
           *> Mostramos los datos de la cita
           invoke MostrarDatosCita().
           goback.
       end method.

       *>
       *> MostrarDatosCita
       *>
       *> Carga los datos de la cita en los campos de la vista
       *>
       method-id MostrarDatosCita.
       procedure division.
           set cita to type CitaMe.vista.VentanaPrincipal::DevuelveInstancia()::CitaIniciada.
           set Nombre::Text to cita::paciente::usuario::nombre_real_usr.
           set Apellidos::Text to cita::paciente::usuario::apellidos_usr.
           set Comunidad::Text to cita::paciente::comunidad.
           set DNI::Text to cita::paciente::dni.
           set SeguridadSocial::Text to cita::paciente::seguridad_social.
           set FechaNacimiento::Text to cita::paciente::usuario::fechaNacimiento_usr.
           set Sexo::Text to cita::paciente::sexo.
           set Genero::Text to cita::paciente::genero.
           set MotivoCita::Text to cita::motivo_cita.
          set FechaCita::Content to cita::fecha_cita::ToString("dd/MM/yyyy").
          set HoraCita::Content to cita::hora_cita::ToString("hh\:mm").
           goback.
       end method.

       *>
       *> BotonCerrarDiagnostico
       *>
       *> Si el médico a escrito un diagnóstico lo registra en la base de datos
       *> y vuelve a la vista inicial.
       *>
       method-id BotonCerrarDiagnostico final private.
       procedure division using by value sender as object e as type System.Windows.RoutedEventArgs.

          if Diagnostico::Text::Trim()::Equals("")
               invoke type MessageBox::Show("Introduzca un diagnóstico para el paciente.", "Error - Formulario", type MessageBoxButton::OK, type MessageBoxImage::Warning)
               goback
          end-if

          if not modeloCita::RegistrarDiagnostico(cita::id_cita, Diagnostico::Text)
              invoke type MessageBox::Show("Ha ocurrido un error registrando el diagnóstico en la base de datos.", "Error - Base de datos", type MessageBoxButton::OK, type MessageBoxImage::Error)
              goback
          end-if

          invoke vtnPrincipal::CambiarFrame("/vista/medico/Medico.xaml").

          goback.
       end method.

       *>
       *> BotonIrInicio
       *>
       *> Carga la vista de inicio del médico
       *>
       method-id BotonIrInicio final private.
       procedure division using by value sender as object e as type System.Windows.RoutedEventArgs.
          invoke vtnPrincipal::CambiarFrame("/vista/medico/Medico.xaml")
          goback.
       end method.

       *>
       *> BotonSalir
       *>
       *> Carga la vista al Login
       *>
       method-id BotonSalir final private.
       procedure division using by value sender as object e as type System.Windows.RoutedEventArgs.
          invoke vtnPrincipal::CambiarFrame("/vista/Login.xaml").
          goback.
       end method.

       *>
       *> BotonIrCitas
       *>
       *> Carga la vista para ver las citas
       *>
       method-id BotonIrCitas final private.
       procedure division using by value sender as object e as type System.Windows.RoutedEventArgs.
          invoke vtnPrincipal::CambiarFrame("/vista/Medico/VerCitas.xaml").
          goback.
       end method.


       end class.
