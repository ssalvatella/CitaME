       *>
       *> Medico
       *>
       *> Clase de control de la vista que
       *> muestra la vista de inicio del médico.
       *>
       *> Autor: Samuel Salvatella
       *> Ultima modificación: 02/01/2018
       *>
       class-id CitaMe.vista.Medico is partial
                 inherits type System.Windows.Controls.Page.

       working-storage section.

       01 vtnPrincipal type CitaMe.vista.VentanaPrincipal.
       01 modeloCita type CitaMe.modelo.Cita.
       01 citaSeleccionada type CitaMe.modelo.Cita.

       method-id NEW.
       procedure division.
           invoke self::InitializeComponent()
           *> Cargamos el modelo de cita para usuarlo
           set modeloCita to new CitaMe.modelo.Cita().
            *> Guardamos la referencia a la ventana principal
           set vtnPrincipal to type CitaMe.vista.VentanaPrincipal::DevuelveInstancia().
           invoke MostrarCitas().
           goback.
       end method.

       *>
       *> MostrarCitas
       *>
       *> Muestra las próximas citas del médico en la tabla
       *>
       method-id MostrarCitas final private.
       01 citas List[type CitaMe.modelo.Cita].
       procedure division.
           *> Obtenemos las citas
           set citas to modeloCita::DevuelveCitasMedico(type CitaMe.vista.Login::idUsuario, True).
           invoke tablaCitasHoy::Items::Clear().
           *> Ponemos los usuarios obtenidos en la tabla
           perform varying cita as type CitaMe.modelo.Cita through citas
               invoke tablaCitasHoy::Items::Add(cita)
           end-perform.

       end method.

       *>
       *> BotonCancelarCita
       *>
       *> Dada la cita seleccionada en la tabla la cancela
       *> si el usuario confirma la acción.
       *>
       method-id BotonCancelarCita final private.
       local-storage section.
       01 accionConfirmada type MessageBoxResult.
       procedure division using by value sender as object e as type System.Windows.RoutedEventArgs.
           *> Preguntamos al usuario si esta seguro de cancelar la cita
           set accionConfirmada to type MessageBox::Show("¿Está seguro de que desea cancelar la cita?", "Confirmar acción", type MessageBoxButton::YesNo, type MessageBoxImage::Warning).
           *> Obtenemos la cita seleccionada
           set citaSeleccionada to tablaCitasHoy::SelectedItem as type CitaMe.modelo.Cita.
           if accionConfirmada::Equals(type MessageBoxResult::Yes)
               *> Se registra la cancelación de la cita
               if modeloCita::CancelarCita(citaSeleccionada::id_cita)
                   *> En caso de éxito en la cancelación
                   invoke MostrarCitas()
                   set TarjetaCita::Visibility to type Visibility::Collapsed
                   invoke type MessageBox::Show("Cita cancelada con éxito.", "Cita cancelada", type MessageBoxButton::OK, type MessageBoxImage::Information)
               else
                   *> En caso de error
                   invoke type MessageBox::Show("Ha ocurrido un error inesperado cancelando la cita.", "Error cancelación de cita", type MessageBoxButton::OK, type MessageBoxImage::Warning)
               end-if
           else
               goback
           end-if
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
       *> BotonIniciarCita
       *>
       *> Carga la vista para iniciar la cita y registrar el diagnóstico
       *>
       method-id BotonIniciarCita final private.
       procedure division using by value sender as object e as type System.Windows.RoutedEventArgs.

          invoke vtnPrincipal::EstablecerCitaIniciada(citaSeleccionada).
          invoke vtnPrincipal::CambiarFrame("/vista/medico/IniciarCita.xaml").
          goback.
       end method.

       *>
       *> CitaSeleccionada
       *>
       *> Se ejecuta cuando se selecciona una cita y se muestran
       *> los datos de esta en el panel auxiliar.
       *>
       method-id CitaSeleccionada final private.
       local-storage section.
       procedure division using by value sender as object e as type System.Windows.Controls.SelectionChangedEventArgs.

          set citaSeleccionada to tablaCitasHoy::SelectedItem as type CitaMe.modelo.Cita.

          if citaSeleccionada = null
              goback
          end-if
          set TarjetaCita::Visibility to type Visibility::Visible.

          *> Ponemos los datos del usuario en la tarjeta de edición
          set FechaCita::Content to citaSeleccionada::fecha_cita::ToString("dd/MM/yyyy").
          set HoraCita::Content to citaSeleccionada::hora_cita::ToString("hh\:mm").
          set TextoMotivo::Text to citaSeleccionada::motivo_cita.
          set TextoPaciente::Text to type String::Concat(citaSeleccionada::paciente::usuario::nombre_real_usr," ", citaSeleccionada::paciente::usuario::apellidos_usr).

          goback.
       end method.


       end class.
