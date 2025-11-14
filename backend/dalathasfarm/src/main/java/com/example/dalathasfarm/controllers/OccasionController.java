package com.example.dalathasfarm.controllers;

import com.example.dalathasfarm.dtos.OccasionDto;
import com.example.dalathasfarm.models.Occasion;
import com.example.dalathasfarm.responses.ResponseObject;
import com.example.dalathasfarm.services.Occasion.IOccasionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("${api.prefix}/occasions")
public class OccasionController {
    private final IOccasionService occasionService;

    @PostMapping("")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<ResponseObject> createOccasion(
            @Valid @RequestBody OccasionDto occasionDto,
            BindingResult result) throws Exception {
        if (result.hasErrors()) {
            List<String> errorMessage = result.getFieldErrors()
                    .stream()
                    .map(FieldError::getDefaultMessage)
                    .toList();
            return ResponseEntity.badRequest().body(ResponseObject.builder()
                    .message(String.join("; ", errorMessage))
                    .status(HttpStatus.BAD_REQUEST)
                    .build());
        }
        Occasion occasion = occasionService.createOccasion(occasionDto);
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Create occasion successfully")
                .status(HttpStatus.CREATED)
                .data(occasion)
                .build());
    }

    @GetMapping("")
    public ResponseEntity<ResponseObject> getAllOccasion(
            @RequestParam("page") int page,
            @RequestParam("limit") int limit
    ) {
        List<Occasion> occasions = occasionService.getAllOccasion();
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Get list of occasions successfully")
                .status(HttpStatus.OK)
                .data(occasions)
                .build());
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<ResponseObject> updateOccasion(
            @PathVariable Integer id,
            @Valid @RequestBody OccasionDto occasionDto
    ) throws Exception {
        Occasion occasion = occasionService.updateOccasion(id, occasionDto);
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Update occasion successfully")
                .status(HttpStatus.OK)
                .data(occasion)
                .build());
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<ResponseObject> deleteOccasion(@PathVariable Integer id) throws Exception {
        occasionService.deleteOccasion(id);
        return ResponseEntity.ok(ResponseObject.builder()
                .status(HttpStatus.OK)
                .message("Delete occasion successfully")
                .data(null)
                .build());
    }

    @GetMapping("/{id}")
    public ResponseEntity<ResponseObject> getOccasionById(
            @PathVariable Integer id
    ) throws Exception {
        Occasion occasion = occasionService.getOccasionById(id);
        return ResponseEntity.ok(ResponseObject.builder()
                .data(occasion)
                .message("Get occasion information successfully")
                .status(HttpStatus.OK)
                .build());
    }

    @GetMapping("/active/today")
    public ResponseEntity<ResponseObject> getTodayOccasions() {
        List<Occasion> occasions = occasionService.getActiveOccasionsForToday();
        return ResponseEntity.ok(ResponseObject.builder()
                .data(occasions)
                .message("Get occasions for today successfully")
                .status(HttpStatus.OK)
                .build());
    }
}
