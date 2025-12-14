package com.example.dalathasfarm.controllers;

import com.example.dalathasfarm.components.LocalizationUtils;
import com.example.dalathasfarm.dtos.CategoryDto;
import com.example.dalathasfarm.models.Category;
import com.example.dalathasfarm.responses.ResponseObject;
import com.example.dalathasfarm.services.Category.ICategoryService;
import com.example.dalathasfarm.utils.MessageKeys;
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
@RequestMapping("${api.prefix}/categories")
// Dependency Injection
@RequiredArgsConstructor
public class CategoryController {
    private final ICategoryService categoryService;
    private final LocalizationUtils localizationUtils;

    @PostMapping("")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<ResponseObject> createCategory(
            @Valid @RequestBody CategoryDto categoryDto,
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
        Category category = categoryService.createCategory(categoryDto);
        return ResponseEntity.ok(ResponseObject.builder()
                .message(localizationUtils.getLocalizedMessage(MessageKeys.INSERT_LOAISANPHAM_SUCCESSFULLY))
                .status(HttpStatus.CREATED)
                .data(category)
                .build());
    }

    @GetMapping("")
    public ResponseEntity<ResponseObject> getAllCategory(
            @RequestParam("page") int page,
            @RequestParam("limit") int limit
    ) {
        List<Category> categories = categoryService.getAllCategory();
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Get list of categories successfully")
                .status(HttpStatus.OK)
                .data(categories)
                .build());
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<ResponseObject> updateCategory(
            @PathVariable Integer id,
            @Valid @RequestBody CategoryDto categoryDto
    ) throws Exception {
        Category category = categoryService.updateCategory(id, categoryDto);
        return ResponseEntity.ok(ResponseObject.builder()
                .message(localizationUtils.getLocalizedMessage(MessageKeys.UPDATE_LOAISANPHAM_SUCCESSFULLY))
                .status(HttpStatus.OK)
                .data(category)
                .build());
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<ResponseObject> deleteCategory(@PathVariable Integer id) throws Exception {
        categoryService.deleteCategory(id);
        return ResponseEntity.ok(ResponseObject.builder()
                .status(HttpStatus.OK)
                .message(localizationUtils.getLocalizedMessage(MessageKeys.DELETE_LOAISANPHAM_SUCCESSFULLY, id))
                .data(null)
                .build());

        //return ResponseEntity.ok(localizationUtils.getLocalizedMessage(MessageKeys.DELETE_LOAISANPHAM_SUCCESSFULLY, id));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ResponseObject> getCategoryById(
            @PathVariable Integer id
    ) throws Exception {
        Category category = categoryService.getCategoryById(id);
        return ResponseEntity.ok(ResponseObject.builder()
                .data(category)
                .message("Get category information successfully")
                .status(HttpStatus.OK)
                .build());
    }
}
