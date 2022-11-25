 <!-- Main Sidebar Container -->
 <link rel="stylesheet" href="css/estilos-aside.css">
<aside class="main-sidebar sidebar-dark-primary elevation-4" style="background-color: rgb(20, 83, 154);">
      <!-- Brand Logo -->
      <div style="background: #023e8a">
      <p href="index3.html" class="brand-link">
          <img src="vistas/img/logo.png"  class="brand-image img-circle elevation-3">
          <span class="brand-text font-weight-black">Cigarreria EDBAR</span></p>
      </div>
      <!-- Sidebar -->
      <div class="sidebar" >
          <!-- Sidebar user panel (optional) -->
          <div class="user-panel mt-3 pb-3 mb-3 d-flex" >
              <div class="f_perfil">
                  <img src="vistas/imagenes/avatar-de-hombre.png" style="width: 55px; height: 55px;" class="img_perfil">
              </div>
              <div class="info">
                  <p class="n_rol">Juan Montenegro</p>
              </div>
          </div>
          <hr>
          <!-- Sidebar Menu -->
         <nav class="mt-2">

<ul class="nav nav-pills nav-sidebar flex-column nav-child-indent" data-widget="treeview" role="menu"
    data-accordion="false">

    <li class="nav-item active">
        <a style="cursor: pointer;" class="nav-link active" onclick="CargarContenido('vistas/dashboard.php','content-wrapper')">
        <img src="vistas/imagenes/boton-de-inicio.png" style="height: 27px; width:27px">
            <p style="font-size: 18px">
               Pagina Principal
            </p>
        </a>
    </li>

     <li class="nav-item">
         <a style="cursor: pointer;" class="nav-link" onclick="CargarContenido('vistas/productos.php','content-wrapper')">
         <img src="vistas/imagenes/inventario.png" style="height: 27px; width:27px">
             <p style="font-size: 18px">
                 Inventario
             </p>
         </a>
     </li>
     <li class="nav-item">
         <a style="cursor: pointer;" class="nav-link" onclick="CargarContenido('vistas/carga_masiva_productos.php','content-wrapper')">
         <img src="vistas/imagenes/carrito-de-compras.png" style="height: 27px; width:27px">
             <p>
                 Agregar productos
             </p>
         </a>
     </li>
     <li class="nav-item">
         <a style="cursor: pointer;" class="nav-link" onclick="CargarContenido('vistas/ventas.php','content-wrapper')">
         <img src="vistas/imagenes/bienes.png" style="height: 27px; width:27px">
             <p>
                 Ventas
             </p>
         </a>
     </li>
     <li class="nav-item">
         <a style="cursor: pointer;" class="nav-link" onclick="CargarContenido('vistas/compras.php','content-wrapper')">
         <img src="vistas/imagenes/orden.png" style="height: 27px; width:27px">
             <p>
                 Pedidos
             </p>
         </a>
     </li>
     <li class="nav-item">
         <a style="cursor: pointer;" class="nav-link" onclick="CargarContenido('vistas/reportes.php','content-wrapper')">
         <img src="vistas/imagenes/grafico-de-barras.png" style="height: 27px; width:27px">
             <p>
                 Reportes
             </p>
         </a>
     </li>
     <li class="nav-item">
         <a style="cursor: pointer;" class="nav-link" onclick="CargarContenido('crud','content-wrapper')">
             <img src="vistas/imagenes/grupo.png" style="height: 27px; width:27px">
             <p>
                 Usuarios
             </p>
         </a>
         <a style="cursor: pointer;" class="nav-link" onclick="CargarContenido('vistas/configuracion.php','content-wrapper')">
             <img src="vistas/imagenes/configuracion.png" style="height: 27px; width:27px">
             <p>
                 Configuracion
             </p>
         </a>
         <hr>
     </li>
     <div class="sign-off">
         <a href="salir.php" class="btn-sign-off">
         <img src="vistas/imagenes/cerrar-sesion.png" style="height: 27px; width:27px">
             <span>Cerrar Sesión</span>
           </a>
       </div>
 </ul>
</nav>
<!-- /.sidebar-menu -->
</div>
<!-- /.sidebar -->
         
  </aside>
  <script>
      $(".nav-link").on('click', function() {
          $(".nav-link").removeClass('active');
          $(this).addClass('active');
      })
  </script>