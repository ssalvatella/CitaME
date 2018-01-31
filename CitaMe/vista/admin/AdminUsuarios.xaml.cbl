       *>
       *> AdminUsuarios
       *>
       *> Clase de control de la vista que
       *> muestra la tabla de usuarios y el formulario
       *> para registrar nuevos y editarlos.
       *>
       *> Autor: Samuel Salvatella
       *> Ultima modificación: 20/01/2018
       *>
       class-id CitaMe.vista.admin.AdminUsuarios is partial
                 inherits type System.Windows.Controls.Page.

       working-storage section.

       01 vtnPrincipal type CitaMe.vista.VentanaPrincipal.
       01 modeloUsuario type CitaMe.modelo.Usuario.
       01 usuarios type List[type CitaMe.modelo.Usuario].

       method-id NEW.
       procedure division.
           invoke self::InitializeComponent()
           *> Guardamos la referencia a la ventana principal
           set vtnPrincipal to type CitaMe.vista.VentanaPrincipal::DevuelveInstancia().
           *> Cargamos el modelo de usuarios para consultarlo
           set modeloUsuario to new CitaMe.modelo.Usuario().
           invoke ActualizarUsuarios().

           goback.
       end method.

       *>
       *> ActualizarUsuarios
       *>
       *> Obtiene la lista de usuarios y la carga en la tabla
       *> de la vista.
       *>
       method-id ActualizarUsuarios final private.
       procedure division.
           *> Obtenemos los usuarios
           set usuarios to modeloUsuario::DevuelveUsuarios().
           *> Limpiamos la tabla por si había valores antiguos
           invoke tablaUsuarios::Items::Clear().
           *> Ponemos los usuarios obtenidos en la tabla
           perform varying usuario as type CitaMe.modelo.Usuario through usuarios
               invoke tablaUsuarios::Items::Add(usuario)
           end-perform.
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
       *> UsuarioSeleccionado
       *>
       *> Se ejecuta cuando se selecciona un usuario en la tabla
       *> y se muestran los datos del usuario en el panel derecho.
       *>
       method-id UsuarioSeleccionado final private.
       local-storage section.
       01 usuarioSeleccionado type CitaMe.modelo.Usuario.

       procedure division using by value sender as object e as type System.Windows.Controls.SelectionChangedEventArgs.

          *> Obtenemos el usuario seleccionado
          set usuarioSeleccionado to tablaUsuarios::SelectedItem as type CitaMe.modelo.Usuario.
          *> En caso de que no haya ninguno seleccionado se sale de la ejecución
          if usuarioSeleccionado = null
              goback
          end-if
          *> Hacemos visible la tarjeta con los datos del usuario
          set TarjetaUsuario::Visibility to type Visibility::Visible.

          *> Ponemos los datos del usuario en la tarjeta de edición
          set TextoNombreUsuario::Text to usuarioSeleccionado::nombre_real_usr.
          set TextoApellidosUsuario::Text to usuarioSeleccionado::apellidos_usr.
          set TextoTipoUsuario::Text to usuarioSeleccionado::tipo_usr.
          set CampoNombreUsuario::Text to usuarioSeleccionado::nombre_usr.
          set CampoNombre::Text to usuarioSeleccionado::nombre_real_usr.
          set CampoApellidos::Text to usuarioSeleccionado::apellidos_usr.
          if usuarioSeleccionado::activo_usr = 1
              set CandadoActivo::IsChecked to True
          else
              set CandadoActivo::IsChecked to False
          end-if

          goback.
       end method.

       *>
       *> BotonGuardar
       *>
       *> Valida el formulario para editar usuario y en caso de
       *> que sea correcto guarda los datos editados.
       *>
       method-id BotonGuardar final private.
       local-storage section.
       01 usuarioSeleccionado type CitaMe.modelo.Usuario.
       01 usuarioActivo pic 9.
       procedure division using by value sender as object e as type System.Windows.RoutedEventArgs.

           *> Obtenemos el usuario seleccionado que se desea editar
           set usuarioSeleccionado to tablaUsuarios::SelectedItem as type CitaMe.modelo.Usuario.
           *> Validamos los datos que se van a editar
           if type System.String::IsNullOrWhiteSpace(CampoNombreUsuario::Text) or 
             type System.String::IsNullOrWhiteSpace(CampoNombre::Text) or
             type System.String::IsNullOrWhiteSpace(CampoApellidos::Text) 
             invoke type MessageBox::Show("Por favor, rellene todos los datos correctamente.", "Complete Formulario", type MessageBoxButton::OK, type MessageBoxImage::Warning)
           end-if
           if CandadoActivo::IsChecked::GetValueOrDefault
               set usuarioActivo to 1
           else
               set usuarioActivo to 0
           end-if.
           *> Llamamos al modelo para que registre la edición del usuario
           invoke modeloUsuario::EditarUsuario(usuarioSeleccionado::id_usu, CampoNombreUsuario::Text, CampoNombre::Text, CampoApellidos::Text, usuarioActivo).

           *> Actualizamos la tabla de usuarios para que se muestre los datos editados
           invoke ActualizarUsuarios()

       end method.

       *>
       *> MostrarFormularioTipo
       *>
       *> Muestra el formulario correspondiente al tipo
       *> de usuario que se desea mostrar (admin/médico/paciente).
       *>
       method-id MostrarFormularioTipo final private.
       local-storage section.
       01 tipoElegido string.
       procedure division using by value sender as object e as type System.Windows.Controls.SelectionChangedEventArgs.

          *> En caso de que el tipo de usuario no se haya específicado se sale de la ejecución
           if NuevoTipo::SelectedValue = null
               goback
           end-if

           *> Obtenemos el tipo de usuario y en función de este se muestra un formulario u otro
           set tipoElegido to NuevoTipo::SelectedValue::ToString()
           if tipoElegido::Equals("Paciente")
               set FormularioNuevoPaciente::Visibility to type Visibility::Visible
               set FormularioNuevoMedico::Visibility to type Visibility::Collapsed
           else if tipoElegido::Equals("Medico")
               set FormularioNuevoPaciente::Visibility to type Visibility::Collapsed
               set FormularioNuevoMedico::Visibility to type Visibility::Visible
           else
               set FormularioNuevoPaciente::Visibility to type Visibility::Collapsed
               set FormularioNuevoMedico::Visibility to type Visibility::Collapsed
           end-if

       end method.
       
       *>
       *> BotonRegistrarUsuario
       *>
       *> Valida el formulario de registro de usuario. En caso 
       *> de que los datos sean válidos lo registra en la base de datos
       *> y limpia el formulario por si se desea registrar otro nuevo.
       *>
       method-id BotonRegistrarUsuario final private.
       local-storage section.
       01 datosUsuarioValidos type Boolean.
       01 datosPacienteValidos type Boolean.
       01 datosMedicoValidos type Boolean.
       01 idUsuario binary-short.
       procedure division using by value sender as object e as type System.Windows.RoutedEventArgs.

           *> Validamos el formulario
           set datosUsuarioValidos to ValidarFormularioUsuario().
           *> En caso de que no sean correctos los datos salimos de la ejecución
           if not datosUsuarioValidos
               goback
           end-if
           *> Se registra el usuario, en caso de error se muestra un mensaje
           if not modeloUsuario::RegistrarUsuario(NuevoNombreUsuario::Text, NuevoContraseña::Password,
                                                  NuevoNombre::Text, NuevoApellidos::Text, NuevoFechaNacimiento::Text,
                                                 NuevoTipo::SelectedValue::ToString())
               invoke type MessageBox::Show("Ha ocurrido un error grave a la hora de procesar el registro de usuario", "Error - Base de datos",
                                            type MessageBoxButton::OK, type MessageBoxImage::Error)
               goback
           end-if
           *> Obtenemos el ID del usuario recien registrado
           set idUsuario to modeloUsuario::DevuelveIdUsuario(NuevoNombreUsuario::Text).
           *> En función del tipo de usuario registrado validamos unos datos u otros y los registramos
           evaluate NuevoTipo::SelectedValue::ToString()
               *> En caso de usuario Paciente
               when "Paciente"
                   set datosPacienteValidos to ValidarFormularioPaciente()
                   if not datosPacienteValidos
                       goback
                   end-if
                   invoke modeloUsuario::RegistrarPaciente(idUsuario, PacienteNumeroSeguridad::Text, PacienteDNI::Text,
                                                           PacienteComunidad::Text, PacienteSexo::Text, PacienteGenero::Text)
               *> En caso de usuario Médico
               when "Medico"
                   set datosMedicoValidos to ValidarFormularioMedico()
                   if not datosMedicoValidos
                       goback
                   end-if
                   invoke modeloUsuario::RegistrarMedico(idUsuario, MedicoNumeroColegiado::Text, MedicoComunidad::Text,
                                                         MedicoEspecialidad::Text, MedicoFechaPromocion::Text, InicioMañanas::Text,
                                                         FinMañanas::Text, InicioTardes::Text, FinTardes::Text)
           end-evaluate

           *> Limpiamos el formulario por si se desea volver a usar
           invoke LimpiarFormulario().
           *> Volvemos a esconder los formularios de registro
           set TarjetaNuevoUsuario::Visibility to type Visibility::Collapsed.
           set FormularioNuevoPaciente::Visibility to type Visibility::Collapsed
           set FormularioNuevoMedico::Visibility to type Visibility::Collapsed
           *> Actualizamos la tabla para que se muestre el usuario nuevo
           invoke ActualizarUsuarios().

       end method.

       *>
       *> BotonNuevoUsuario
       *>
       *> Hace visible el panel de registro de nuevos usuarios.
       *>
       method-id BotonNuevoUsuario final private.
       procedure division using by value sender as object e as type System.Windows.RoutedEventArgs.
           set TarjetaNuevoUsuario::Visibility to type Visibility::Visible.
       end method.

       *>
       *> BotonCancelarNuevoUsuario
       *>
       *> Limpia el formulario y lo esconde.
       *>
       method-id BotonCancelarNuevoUsuario final private.
       procedure division using by value sender as object e as type System.Windows.RoutedEventArgs.
           set TarjetaNuevoUsuario::Visibility to type Visibility::Collapsed.
           invoke LimpiarFormulario().
       end method.

       *>
       *> LimpiarFormulario
       *>
       *> Limpia todos los campos del formulario
       *>
       method-id LimpiarFormulario final private.
       procedure division.
           set NuevoNombreUsuario::Text to "".
           set NuevoContraseña::Password to "".
           set NuevoRepetirContraseña::Password to "".
           set NuevoTipo::Text to "".
           set NuevoNombre::Text to "".
           set NuevoApellidos::Text to "".
           set NuevoFechaNacimiento::Text to "".
           set MedicoNumeroColegiado::Text to "".
           set MedicoComunidad::Text to "".
           set InicioMañanas::Text to "".
           set InicioTardes::Text to "".
           set MedicoFechaPromocion::Text to "".
           set MedicoEspecialidad::Text to "".
           set FinMañanas::Text to "".
           set FinTardes::Text to "".
           set PacienteNumeroSeguridad::Text to "".
           set PacienteDNI::Text to "".
           set PacienteComunidad::Text to "".
           set PacienteSexo::Text to "".
           set PacienteGenero::Text to "".
       end method.

       *>
       *> ValidarFormularioUsuario
       *>
       *> Comprueba los campos de registro de usuario y en caso de error muestra un mensaje
       *>
       method-id ValidarFormularioUsuario final private.
       procedure division returning valido as type Boolean.
           if NuevoNombreUsuario::Text::Trim()::Equals("")
               invoke type MessageBox::Show("Introduzca un nombre de usuario.", "Error - Formulario", type MessageBoxButton::OK, type MessageBoxImage::Warning)
               set valido to False
               goback
           end-if
           if modeloUsuario::NombreUsuarioExiste(NuevoNombreUsuario::Text)
               invoke type MessageBox::Show("Este nombre de usuario ya existe. Introduzca otro nombre de usuario.", "Error - Formulario", type MessageBoxButton::OK, type MessageBoxImage::Warning)
               set valido to False
               goback
           end-if

           if NuevoContraseña::Password::Trim()::Equals("")
               invoke type MessageBox::Show("Introduzca una contraseña.", "Error - Formulario", type MessageBoxButton::OK, type MessageBoxImage::Warning)
               set valido to False
               goback
           end-if
           if NuevoContraseña::Password::Length < 6
               invoke type MessageBox::Show("Introduzca una contraseña de mínimo 6 carácteres.", "Error - Formulario", type MessageBoxButton::OK, type MessageBoxImage::Warning)
               set valido to False
               goback
           end-if
           if not NuevoContraseña::Password::Equals(NuevoRepetirContraseña::Password)
               invoke type MessageBox::Show("Confirme la contraseña repitiendola en el segundo campo.", "Error - Formulario", type MessageBoxButton::OK, type MessageBoxImage::Warning)
               set valido to False
               goback
           end-if
           if NuevoNombre::Text::Trim()::Equals("")
               invoke type MessageBox::Show("Introduzca un nombre real de la persona.", "Error - Formulario", type MessageBoxButton::OK, type MessageBoxImage::Warning)
               set valido to False
               goback
           end-if
           if NuevoApellidos::Text::Trim()::Equals("")
               invoke type MessageBox::Show("Introduzca los apellidos de la persona.", "Error - Formulario", type MessageBoxButton::OK, type MessageBoxImage::Warning)
               set valido to False
               goback
           end-if
           if NuevoFechaNacimiento::Text::Trim()::Equals("")
               invoke type MessageBox::Show("Introduzca una fecha de nacimiento.", "Error - Formulario", type MessageBoxButton::OK, type MessageBoxImage::Warning)
               set valido to False
               goback
           end-if
           if NuevoTipo::SelectedValue = null
               invoke type MessageBox::Show("Seleccione el tipo de usuario.", "Error - Formulario", type MessageBoxButton::OK, type MessageBoxImage::Warning)
               set valido to False
               goback
           end-if

           set valido to true.
       end method.

       *>
       *> ValidarFormularioMedico
       *>
       *> Comprueba los campos de registro de médico y en caso de error muestra un mensaje
       *>
       method-id ValidarFormularioMedico final private.
       procedure division returning valido as type Boolean.
           if MedicoEspecialidad::Text::Trim()::Equals("")
               invoke type MessageBox::Show("Introduzca la especialidad del médico", "Error - Formulario", type MessageBoxButton::OK, type MessageBoxImage::Warning)
               set valido to False
               goback
           end-if
           if MedicoFechaPromocion::Text::Trim()::Equals("")
               invoke type MessageBox::Show("Introduzca la fecha de promoción del médico.", "Error - Formulario", type MessageBoxButton::OK, type MessageBoxImage::Warning)
               set valido to False
               goback
           end-if
           if MedicoNumeroColegiado::Text::Trim()::Equals("")
               invoke type MessageBox::Show("Introduzca el número de colegiado del médico.", "Error - Formulario", type MessageBoxButton::OK, type MessageBoxImage::Warning)
               set valido to False
               goback
           end-if
           if MedicoComunidad::SelectedValue = null
               invoke type MessageBox::Show("Indique la comunidad autónoma del médico.", "Error - Formulario", type MessageBoxButton::OK, type MessageBoxImage::Warning)
               set valido to False
               goback
           end-if
           if InicioMañanas::Text::Trim()::Equals("")
               invoke type MessageBox::Show("Introduzca el inicio del horario de mañanas.", "Error - Formulario", type MessageBoxButton::OK, type MessageBoxImage::Warning)
               set valido to False
               goback
           end-if
           if FinMañanas::Text::Trim()::Equals("")
               invoke type MessageBox::Show("Introduzca el fin del horario de mañanas.", "Error - Formulario", type MessageBoxButton::OK, type MessageBoxImage::Warning)
               set valido to False
               goback
           end-if
           if InicioTardes::Text::Trim()::Equals("")
               invoke type MessageBox::Show("Introduzca el inicio del horario de tardes.", "Error - Formulario", type MessageBoxButton::OK, type MessageBoxImage::Warning)
               set valido to False
               goback
           end-if

           if FinTardes::Text::Trim()::Equals("")
               invoke type MessageBox::Show("Introduzca el fin del horario de tardes.", "Error - Formulario", type MessageBoxButton::OK, type MessageBoxImage::Warning)
               set valido to False
               goback
           end-if

           set valido to true.
       end method.

       *>
       *> ValidarFormularioPaciente
       *>
       *> Comprueba los campos de registro de paciente y en caso de error muestra un mensaje
       *>
       method-id ValidarFormularioPaciente final private.
       procedure division returning valido as type Boolean.
           if PacienteDNI::Text::Trim()::Equals("")
               invoke type MessageBox::Show("Introduzca el DNI del paciente.", "Error - Formulario", type MessageBoxButton::OK, type MessageBoxImage::Warning)
               set valido to False
               goback
           end-if
           if PacienteNumeroSeguridad::Text::Trim()::Equals("")
               invoke type MessageBox::Show("Introduzca el número de Seguridad Social del paciente.", "Error - Formulario", type MessageBoxButton::OK, type MessageBoxImage::Warning)
               set valido to False
               goback
           end-if
           if PacienteComunidad::SelectedValue = null
               invoke type MessageBox::Show("Indique la comunidad autónoma del paciente.", "Error - Formulario", type MessageBoxButton::OK, type MessageBoxImage::Warning)
               set valido to False
               goback
           end-if
           if PacienteSexo::SelectedValue = null
               invoke type MessageBox::Show("Indique el sexo del paciente.", "Error - Formulario", type MessageBoxButton::OK, type MessageBoxImage::Warning)
               set valido to False
               goback
           end-if
           if PacienteGenero::SelectedValue = null
               invoke type MessageBox::Show("Indique el genero del paciente.", "Error - Formulario", type MessageBoxButton::OK, type MessageBoxImage::Warning)
               set valido to False
               goback
           end-if

           set valido to true.
       end method.

       *>
       *> BotonIrInicio
       *>
       *> Vuelve a la vista de inicio del admin.
       *>
       method-id BotonIrInicio final private.
       procedure division using by value sender as object e as type System.Windows.RoutedEventArgs.
          invoke vtnPrincipal::CambiarFrame("/vista/admin/Admin.xaml").
          goback.
       end method.
       


       end class.