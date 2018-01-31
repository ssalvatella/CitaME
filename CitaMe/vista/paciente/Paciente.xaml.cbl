       *>
       *> Paciente
       *>
       *> Clase de control de la vista de 
       *> inicio para el paciente.
       *>
       *> Autor: Samuel Salvatella
       *> Ultima modificación: 15/01/2018
       *>
       class-id CitaMe.vista.Paciente is partial
                 inherits type System.Windows.Controls.Page.

       working-storage section.

       01 vtnPrincipal type CitaMe.vista.VentanaPrincipal.
       01 medicoModelo type CitaMe.modelo.Medico.
       01 citaModelo type CitaMe.modelo.Cita.
       01 especialidades type List[string].
       method-id NEW.
       procedure division.

           invoke self::InitializeComponent().
           *> Guardamos la referencia a la ventana principal
           set vtnPrincipal to type CitaMe.vista.VentanaPrincipal::DevuelveInstancia().
           *> Cargamos los modelos para consultarlos
           set medicoModelo to new CitaMe.modelo.Medico().
           set citaModelo to new CitaMe.modelo.Cita().
           *> Cargamos la lista de especialidades disponibles
           set especialidades to medicoModelo::DevuelveEspecialidades().
           perform varying especialidad as string through especialidades
               invoke listaEspecialidades::Items::Add(especialidad)
           end-perform.
           invoke MostrarCitas().
           invoke MostrarCitasSinEncuesta().
           goback.
       end method.

       *>
       *> MostrarCitas
       *>
       *> Carga la tabla con las próximas citas del paciente.
       *>
       method-id MostrarCitas final private.
       01 citas List[type CitaMe.modelo.Cita].
       procedure division.
           set citas to citaModelo::DevuelveCitasPaciente(type CitaMe.vista.Login::idUsuario, True).
           invoke tablaCitasPendientes::Items::Clear().
           *> Ponemos las citas obtenidos en la tabla
           perform varying cita as type CitaMe.modelo.Cita through citas
               invoke tablaCitasPendientes::Items::Add(cita)
           end-perform.

       end method.

       *>
       *> MostrarCitasSinEncuesta
       *>
       *> Carga una tabla con la lista de citas ya pasadas
       *> en las que no se ha completado la encuesta.
       *>
       method-id MostrarCitasSinEncuesta final private.
       01 citas List[type CitaMe.modelo.Cita].
       procedure division.
           set citas to citaModelo::DevuelveCitasPacienteSinEncuesta(type CitaMe.vista.Login::idUsuario).

           if citas::Count = 0
               set RecuadroEncuestas::Visibility to type Visibility::Collapsed
               goback
           end-if

           invoke tablaCitasSinEncuesta::Items::Clear().
           *> Ponemos las citas obtenidos en la tabla
           perform varying cita as type CitaMe.modelo.Cita through citas
               invoke tablaCitasSinEncuesta::Items::Add(cita)
           end-perform.

       end method.

       *>
       *> LimpiarFormulario
       *>
       *> Limpiamos el formulario por si se desea pedir una cita nueva.
       *>
       method-id LimpiarFormulario final private.
       procedure division.
           set motivoCita::Text to "".
           set listaHorarios::SelectedIndex to -1.
           set listaEspecialidades::SelectedIndex to -1.
           set candadoEmergencia::IsChecked to False.
       end method.

       *>
       *> BotonPedirCita
       *>
       *> Valida el formulario para pedir cita y en caso
       *> de que sea correcto busca hueco y registra la cita.
       *>
       method-id BotonPedirCita final private.
       local-storage section.
       01 especialidad string.
       01 horario string.
       01 emergencia binary-short.
       01 seleccionHorario type ListBoxItem.
       01 textoHorario type TextBlock.
       01 cita type CitaMe.modelo.Cita.
       01 medico type CitaMe.modelo.Medico.
       procedure division using by value sender as object e as type System.Windows.RoutedEventArgs.

           *> Validamos el formulario, en caso de error se muestra mensaje
          if motivoCita::Text::Trim()::Equals("")
              invoke type MessageBox::Show("Por favor, introduzca un motivo para su cita.", "Complete Formulario", type MessageBoxButton::OK, type MessageBoxImage::Warning)
              goback
          end-if

          if listaEspecialidades::SelectedItem = null
              invoke type MessageBox::Show("Por favor, seleccione una especialidad médica.", "Complete Formulario", type MessageBoxButton::OK, type MessageBoxImage::Warning)
              goback
          end-if

          if listaHorarios::SelectedItem = null
              invoke type MessageBox::Show("Por favor, seleccione un horario de preferencia.", "Complete Formulario", type MessageBoxButton::OK, type MessageBoxImage::Warning)
              goback
          end-if

          *> Leemos los campos del usuario
          set especialidad to listaEspecialidades::SelectedValue::ToString().
          set seleccionHorario to listaHorarios::SelectedItem as type ListBoxItem.
          set textoHorario to seleccionHorario::Content as type TextBlock.
          set horario to textoHorario::Text.
          if candadoEmergencia::IsChecked::GetValueOrDefault
              set emergencia to 1
              set horario to "Indiferente"
          else
              set emergencia to 0
          end-if
          *> Buscamos hueco para la cita y obtenemos la cita resultante
          set cita to citaModelo::Asignar(motivoCita::Text, especialidad, horario, emergencia).
          *> En caso de que no encuentre ningún hueco
          if cita = null
              invoke type MessageBox::Show("No se ha encontrado hueco para su cita.", "Error - Cita", type MessageBoxButton::OK, type MessageBoxImage::Warning)
          else
              *> Le mostramos al usuario la hora y la fecha de su cita, se actualiza la tabla de citas y se limpia el formulario.
              set medico to medicoModelo::DevuelveMedico(cita::medico_cita)
              invoke MostrarCitas()
              invoke LimpiarFormulario()
              invoke type MessageBox::Show(
                   type String::Concat("Se le ha asignado la siguiente cita: \n -> ", cita::fecha_cita::ToString("dd/MM/yyyy"), " a las ", cita::hora_cita::ToString("hh\:mm")
                   , "\n -> Con: ", medico::usuario::nombre_real_usr, " ", medico::usuario::apellidos_usr, "\n -> Especialidad: ", medico::especialidad)::Replace("\n", type Environment::NewLine),
                   "Cita asignada",
                   type MessageBoxButton::OK,
                   type MessageBoxImage::Information
               )
          end-if
          goback.
       end method.

       *>
       *> EncuestaSeleccionada
       *>
       *> Se ejecuta cuando se selecciona una cita
       *> sobre la que se desea hacer una encuesta.
       *>
       method-id EncuestaSeleccionada final private.
       local-storage section.
       01 citaSeleccionada type CitaMe.modelo.Cita.
       procedure division using by value sender as object e as type System.Windows.Controls.SelectionChangedEventArgs.

          set citaSeleccionada to tablaCitasSinEncuesta::SelectedItem as type CitaMe.modelo.Cita.

          if citaSeleccionada = null
              set BotonEncuestas::IsEnabled to False
              goback
          end-if

          set BotonEncuestas::IsEnabled to True

          goback.
       end method.

       *>
       *> CompletarEncuesta
       *>
       *> Carga la vista para completar la encuesta sobre
       *> la cita seleccionada en la lista.
       *>
       method-id CompletarEncuesta final private.
       01 citaSeleccionada type CitaMe.modelo.Cita.
       procedure division using by value sender as object e as type System.Windows.RoutedEventArgs.
          invoke vtnPrincipal::CambiarFrame("/vista/paciente/RellenarEncuesta.xaml").
          set citaSeleccionada to tablaCitasSinEncuesta::SelectedItem as type CitaMe.modelo.Cita.
          invoke vtnPrincipal::EstablecerCitaIniciada(citaSeleccionada).
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
          invoke vtnPrincipal::CambiarFrame("/vista/Login.xaml").
          goback.
       end method.


       end class.
