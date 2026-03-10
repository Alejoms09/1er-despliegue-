package com.desplegar._erdespliegue.task;

import java.time.Instant;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Service
public class TaskService {

    private static final String NOT_FOUND_MESSAGE = "Tarea no encontrada";

    private final TaskRepository taskRepository;

    public TaskService(TaskRepository taskRepository) {
        this.taskRepository = taskRepository;
    }

    public Flux<Task> findAll() {
        return taskRepository.findAll();
    }

    public Mono<Task> findById(Long id) {
        return taskRepository.findById(id);
    }

    public Mono<Task> create(TaskRequest request) {
        Task task = new Task(
                null,
                request.title().trim(),
                Boolean.TRUE.equals(request.completed()),
                Instant.now()
        );
        return taskRepository.save(task);
    }

    public Mono<Task> update(Long id, TaskRequest request) {
        return taskRepository.findById(id)
                .switchIfEmpty(Mono.error(new ResponseStatusException(HttpStatus.NOT_FOUND, NOT_FOUND_MESSAGE)))
                .flatMap(existingTask -> {
                    existingTask.setTitle(request.title().trim());
                    existingTask.setCompleted(Boolean.TRUE.equals(request.completed()));
                    return taskRepository.save(existingTask);
                });
    }

    public Mono<Void> delete(Long id) {
        return taskRepository.findById(id)
                .switchIfEmpty(Mono.error(new ResponseStatusException(HttpStatus.NOT_FOUND, NOT_FOUND_MESSAGE)))
                .flatMap(task -> taskRepository.deleteById(task.getId()));
    }
}
