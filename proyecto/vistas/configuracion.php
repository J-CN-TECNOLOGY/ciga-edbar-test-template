 <!-- Content Header (Page header) -->
 <div class="content-header">
     <div class="container-fluid">
         <div class="row mb-2">
             <div class="col-sm-6">
                 <h1 class="m-0">Configuración del Sistema</h1>
             </div><!-- /.col -->
             <div class="col-sm-6">
                 <ol class="breadcrumb float-sm-right">
                     <li class="breadcrumb-item"><a href="#">Inicio</a></li>
                     <li class="breadcrumb-item active">Configuración del Sistema</li>
                 </ol>
             </div><!-- /.col -->
         </div><!-- /.row -->
     </div><!-- /.container-fluid -->
 </div>
 <!-- /.content-header -->

 <!-- Main content -->
 <div class="content">
     <div class="container-fluid">

         <body>
             <div class="container">
                 <div class="row">
                     <div class="col-lg-10; center">
                         <div class="card">
                             <div class="card-header bg-primary">
                                 <h3 class="text-center">Datos de la empresa</h3>
                             </div>
                             <div class="card-body">
                                 <form action="" method="post" id="frm">
                                     <div class="form-group">
                                         <label for=""> Razon social</label>
                                         <input type="text" name="razon social" id="razon social" placeholder="Nombre" class="form-control">
                                     </div>

                                     <div class="form-group">
                                         <label for="">Rut</label>
                                         <input type="text" name="rut" id="rut" placeholder="rut" class="form-control">
                                     </div>
                                     <div class="form-group">

                                         <label for="">Direccion</label>
                                         <input type="hidden" name="idp" id="idp" value="">
                                         <input type="text" name="direccion" id="direccion" placeholder="direccion" class="form-control">
                                     </div>

                                     <div class="form-group">
                                         <label for="">E-mail</label>
                                         <input type="text" name="e-mail" id="e-mail" placeholder="e-mail" class="form-control">
                                     </div>
                                     <div class="form-group">
                                         <input type="button" value="Actualizar" id="actualizar" class="btn btn-primary btn-block">
                                     </div>
                                 </form>
                             </div>
                         </div>
                     </div>


                     </tbody>
                     </table>
                 </div>
             </div>
     </div>
     <script src="script.js"></script>
     <script src="https://cdn.jsdelivr.net/npm/sweetalert2@10"></script>


 </div><!-- /.container-fluid -->
 </div>
 <!-- /.content -->
 <script src="https://cdn.jsdelivr.net/">
function Editar(id) {
    fetch("editar.php", {
        method: "POST",
        body: id
    }).then(response => response.json()).then(response => {
        idp.value = response.id;
        codigo.value = response.codigo;
        producto.value = response.producto;
        precio.value = response.precio;
        cantidad.value = response.cantidad;
        registrar.value = "Actualizar"
    })
}