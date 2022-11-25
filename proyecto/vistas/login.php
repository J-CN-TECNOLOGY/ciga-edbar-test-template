<!DOCTYPE html>
<html lang="es">


    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Cigarreria EDBAR | Login</title>

    <!-- Google Font: Source Sans Pro -->
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700&display=fallback">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="vistas/assets/plugins/fontawesome-free/css/all.min.css">
    <!-- icheck bootstrap -->
    <link rel="stylesheet" href="vistas/assets/plugins/icheck-bootstrap/icheck-bootstrap.min.css">
    <!-- Theme style -->
    <link rel="stylesheet" href="vistas/assets/dist/css/adminlte.min.css">
</head>

<body class="hold-transition login-page">
    <div class="login-box">
        <div class="card card outline card-primary">
            <div class="card-header text-center">
                <h1 class="h1"><b>Cigarreria EDBAR</b></h1>
            </div>  <!-- /.card header -->
            <div class="card body">

                <!-- FORMULARIO DE INICIO DE SECCION -->
                <form method="POST" class="needs-validation-login" novalidate>
                    <!-- USUARIO DEL SISTEMA -->
                    <div class="input-group mb-3">

                        <input class="form-control" type="text" placeholder="Usuario" name="loginUsuario" required>

                            <div class="input-group-append">
                                <div class="input-group-text">
                                    <span class="fas fa-user"></span>

                                </div>
                            </div>
                            <div class="invalid-feedback">Debe ingresar su usuario.</div>
                        </div>
                        <!-- CONTRASEÑA DEL USUARIO -->
                        <div class="input-group mb-3">
                            <input class="form-control" type="password" placeholder="Contraseña" name="loginPassword" required>
                                <div class="input-group-append">
                                    <div class="input-group-text">
                                        <span class="fas fa-lock"></span>

                                    </div>
                                </div>
                                <div class="invalid-feedback">Debe ingresar su contraseña.</div>
                            </div>
                            <!-- BOTON DE INGRESO AL SISTEMA -->
                            <div class="row">
                                <?php
                                $login = new UsuarioControlador();
                                $login->login();
                                ?>
                            </div>
                            <div class="col-md-12 text-center">
                                <button type="submit" class="btn btn-info">Iniciar seccion</button>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>



    <!-- jQuery -->
    <script src="vistas/assets/plugins/jquery/jquery.min.js"></script>
    <!-- Bootstrap 4 -->
    <script src="vistas/assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
    <!-- AdminLTE App -->
    <script src="vistas/assets/dist/js/adminlte.min.js"></script>
</body>

</html> 