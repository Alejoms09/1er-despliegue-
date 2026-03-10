package com.desplegar._erdespliegue;

import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class StatusController {

    @GetMapping("/")
    public Map<String, String> home() {
        return Map.of(
                "message", "API reactiva en linea",
                "tasksEndpoint", "/api/tasks"
        );
    }
}
