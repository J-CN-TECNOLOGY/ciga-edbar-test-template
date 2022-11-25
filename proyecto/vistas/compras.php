 <!-- Content Header (Page header) -->
 <div class="content-header">
     <div class="container-fluid">
         <div class="row mb-2">
             <div class="col-sm-6">
                 <h1 class="m-0">Compras</h1>
             </div><!-- /.col -->
             <div class="col-sm-6">
                 <ol class="breadcrumb float-sm-right">
                     <li class="breadcrumb-item"><a href="#">Inicio</a></li>
                     <li class="breadcrumb-item active">Compras</li>
                 </ol>
             </div><!-- /.col -->
         </div><!-- /.row -->
     </div><!-- /.container-fluid -->
 </div>
 <!-- /.content-header -->

 <!-- Main content -->
 <div class="content">
     <div class="container-fluid">

     </div><!-- /.container-fluid -->
 </div>
 <!-- /.content -->
 <body>
    <div class="container">
        <div class="row">
            <div class="col-lg-10">
                <div class="card">
                    <div class="card-header bg-primary">
                        <h3 class="text-center">Registro de pedidos</h3>
                    </div>
                    <div class="card-body">
                        <form action="" method="post" id="frm">
                            <div class="form-group">
                                <label for="">Numero de factura</label>
                                <input type="hidden" name="idp" id="idp" value="">
                                <input type="text" name="factura" id="factura" placeholder="factura" class="form-control">
                            </div>
                            <div class="form-group">
                                <label for="">Fecha recibido</label>
                                <input type="date" name="fecha" id="fecha" placeholder="fecha" class="dateform-control">
                            </div>
                            <div class="form-group">
                                <label for="">Descripcion Producto</label>
                                <input type="text" name="producto" id="producto" placeholder="Descripción"
                                    class="form-control">
                            </div>
                            <div class="form-group">
                                <label for="">Total a pagar</label>
                                <input type="numeric" name="total" id="total" placeholder="total" class="form-control">
                            </div>
                            <div class= "form-group">
                                <label for="">Proveedor</label>
                                <input type="text" name="proveedor" id="proveedor" placeholder="ID proveedor" class="form-control">
                            </div>
                            <div class= "form-group">
                                <label for="">Empleado</label>
                                <input type="text" name="empleado" id="empleado" placeholder="Quien recibe"  class="form-control">
                            </div>
                            <div class="form-group">
                                <input type="button" value="Registrar" id="registrar" class="btn btn-primary btn-block">
                            </div>
                        </form>
                    </div>
                </div>
            </div>
            <div class="col-lg-8">
                <div class="row">
                    <div class="col-lg-6 ml-auto">
                        <form action="" method="post">
                            <div class="form-group">
                                <label for="buscra">Buscar:</label>
                                <input type="text" name="buscar" id="buscar" placeholder="Buscar..."
                                    class="form-control">
                            </div>
                        </form>
                    </div>
                </div>
                <table class="table table-hover table-resposive">
                    <thead class="thead-dark">
                        <tr>
                            <th>Numero de factura</th>
                            <th>Fecha recibido</th>
                            <th>Total a pagar</th>
                            <th>Proveedor</th>
                            <th>Empleado</th>
                        </tr>
                    </thead>
                    <tbody id="resultado">

                    </tbody>
                </table>
            </div>
        </div>
    </div>
    <script src="script.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@10"></script>
</body>

</html>