<?php
class UsuarioControlador{
    // login de usuarios
    public function login(){
        if(isset($_POST["loginUsuario"])){
            // Realizamos la consulta con los datos del usuario
            $usuario = $_POST["loginUsuario"];
            $password =$_POST["loginPassword"];
            // $password = crypt( $_POST["loginPassword"], '$2a$07$azybxcags23425sdg23sdfhsd$');

            $respuesta = UsuarioModelo::mdlIniciarSeccion($usuario, $password);
            if(count($respuesta) > 0){

                $_SESSION["usuario"] = $respuesta[0];

                echo '
                    <script>
                        window.location = "http://localhost/CIGA_EDBAR/"
                    </script>
                    ';
            }else{
                echo '
                <script>
                    fncSweetAlert(
                        "error",
                        "Usuario y / o contraseña incorrecta",
                        "http://localhost/CIGA_EDBAR/"
                    );
                </script>
                ';
            }

        }
    }
}