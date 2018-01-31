       *>
       *> Login
       *>
       *> Clase de control de la vista que
       *> muestra el login para la identificación
       *> de usuarios.
       *>
       *> Autor: Samuel Salvatella
       *> Ultima modificación: 02/11/2018
       *>
       class-id CitaMe.vista.Login is partial
                 inherits type System.Windows.Controls.Page.

       working-storage section.

       01 idUsuario property static binary-short.

       01 vtnPrincipal type CitaMe.vista.VentanaPrincipal.

       01 NombreUsuario pic X(16).
	   01 ContraseniaUsuario pic X(32).
       01 Usuario type CitaMe.modelo.Usuario.

       method-id NEW.
       procedure division.
           invoke self::InitializeComponent().
           set vtnPrincipal to type CitaMe.vista.VentanaPrincipal::DevuelveInstancia().

           *> Creamos el modelo Usuario para consultar en él
           set Usuario to new CitaMe.modelo.Usuario().
           goback.
       end method.

       *>
       *> Click_BotonEntrar
       *>
       *> Se ejecuta al pulsar entrar y realiza la
       *> identificación del usuario.
       *>
       method-id Click_BotonEntrar final private.
       local-storage section.

       01 UsuarioValido pic 9.
       01 UsuarioActivo pic 9.
       01 TipoUsuario pic 9.
       procedure division using by value sender as object e as type System.Windows.RoutedEventArgs.

          *> Se obtiene el contenido introducido por el usuario
	      set NombreUsuario to textoUsuario::Text.
	      set ContraseniaUsuario to textoContrasenia::Password.
          
          *> Se comprueba que sea un usuario válido
          set UsuarioValido to Usuario::EsValido(NombreUsuario, ContraseniaUsuario).
          *> En caso de usuario/contraseña incorrectos...
          if not UsuarioValido = 1
            invoke type MessageBox::Show("Usuario o contraseña incorrectos", "Error - Identificación", type MessageBoxButton::OK, type MessageBoxImage::Warning)
            goback
           end-if.
          *> Se comprueba que el usuario este activo
          set UsuarioActivo to Usuario::EstaActivo(NombreUsuario).
          if not UsuarioActivo = 1
            invoke type MessageBox::Show("Su usuario ha sido desactivado", "Error - Identificación", type MessageBoxButton::OK, type MessageBoxImage::Warning)
            goback
          end-if.
         *> Comprobamos el tipo de usuario
          set TipoUsuario to Usuario::DevuelveTipo(NombreUsuario).
         *> Según el tipo de usuario cargamos una ventana u otra
          evaluate TipoUsuario
          when type CitaMe.modelo.Usuario::TIPO_ADMINISTRADOR
            set idUsuario to Usuario::DevuelveIdUsuario(NombreUsuario)
            invoke vtnPrincipal::CambiarFrame("/vista/admin/Admin.xaml")
          when type CitaMe.modelo.Usuario::TIPO_MEDICO
            set idUsuario to Usuario::DevuelveIdUsuario(NombreUsuario)
            invoke vtnPrincipal::CambiarFrame("/vista/medico/Medico.xaml")
          when type CitaMe.modelo.Usuario::TIPO_PACIENTE
            set idUsuario to Usuario::DevuelveIdUsuario(NombreUsuario)
            invoke vtnPrincipal::CambiarFrame("/vista/paciente/Paciente.xaml")
          end-evaluate.
       end method.

       end class.
