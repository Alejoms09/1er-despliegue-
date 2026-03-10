package com.desplegar._erdespliegue.task;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record TaskRequest(
        @NotBlank(message = "El titulo es obligatorio")
        @Size(max = 120, message = "El titulo debe tener maximo 120 caracteres")
        String title,
        Boolean completed
) {
}
