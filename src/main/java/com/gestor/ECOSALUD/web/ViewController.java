package com.gestor.ECOSALUD.web;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * Controlador de vistas de ECOSALUD.
 * <p>
 * Cada metodo mapea una ruta con su plantilla Thymeleaf correspondiente
 * (src/main/resources/templates/...). Por ahora solo se resuelve la vista;
 * la carga de datos reales se conecta modulo por modulo mas adelante
 * (Services + Repositories) agregando atributos al Model.
 */
@Controller
public class ViewController {

    // ---------------------------------------------------------------- Inicio
    @GetMapping("/")
    public String inicio() {
        return "home/index";
    }

    // ---------------------------------------------------------- Marketing y Ventas
    @GetMapping("/pacientes")
    public String pacientes() {
        return "marketing/pacientes";
    }

    @GetMapping("/servicios")
    public String servicios() {
        return "marketing/servicios";
    }

    @GetMapping("/solicitudes-cita")
    public String solicitudesCita() {
        return "marketing/solicitudes-cita";
    }

    @GetMapping("/citas")
    public String citas() {
        return "marketing/citas";
    }

    // ---------------------------------------------------------------- Atencion
    @GetMapping("/agenda")
    public String agenda() {
        return "atencion/agenda";
    }

    @GetMapping("/recepcion")
    public String recepcion() {
        return "atencion/recepcion";
    }

    // ------------------------------------------------------------- Operaciones
    @GetMapping("/atenciones")
    public String atenciones() {
        return "operaciones/atenciones";
    }

    @GetMapping("/atencion-detalle")
    public String atencionDetalle() {
        return "operaciones/atencion-detalle";
    }

    @GetMapping("/agenda-especialistas")
    public String agendaEspecialistas() {
        return "operaciones/agenda-especialistas";
    }

    @GetMapping("/agenda-equipos")
    public String agendaEquipos() {
        return "operaciones/agenda-equipos";
    }

    @GetMapping("/informes")
    public String informes() {
        return "operaciones/informes";
    }

    // ------------------------------------------------------ Logistica y Almacen
    @GetMapping("/inventario")
    public String inventario() {
        return "logistica/inventario";
    }

    @GetMapping("/movimientos")
    public String movimientos() {
        return "logistica/movimientos";
    }

    @GetMapping("/compras")
    public String compras() {
        return "logistica/compras";
    }

    @GetMapping("/proveedores")
    public String proveedores() {
        return "logistica/proveedores";
    }

    // ----------------------------------------------------------- Mantenimiento
    @GetMapping("/equipos")
    public String equipos() {
        return "mantenimiento/equipos";
    }

    @GetMapping("/mantenimiento")
    public String mantenimiento() {
        return "mantenimiento/mantenimiento";
    }

    @GetMapping("/historial-equipo")
    public String historialEquipo() {
        return "mantenimiento/historial-equipo";
    }

    // ---------------------------------------------------------------- Gerencia
    @GetMapping("/dashboard-gerencial")
    public String dashboardGerencial() {
        return "gerencia/dashboard-gerencial";
    }

    @GetMapping("/indicadores")
    public String indicadores() {
        return "gerencia/indicadores";
    }

    @GetMapping("/reportes")
    public String reportes() {
        return "gerencia/reportes";
    }

    // ----------------------------------------------------------- Administracion
    @GetMapping("/usuarios")
    public String usuarios() {
        return "administracion/usuarios";
    }

    @GetMapping("/roles")
    public String roles() {
        return "administracion/roles";
    }

    @GetMapping("/permisos")
    public String permisos() {
        return "administracion/permisos";
    }
}
