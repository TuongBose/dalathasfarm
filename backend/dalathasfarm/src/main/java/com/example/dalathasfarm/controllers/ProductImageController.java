package com.example.dalathasfarm.controllers;

import com.example.dalathasfarm.exceptions.DataNotFoundException;
import com.example.dalathasfarm.models.ProductImage;
import com.example.dalathasfarm.responses.ResponseObject;
import com.example.dalathasfarm.services.ProductImage.IProductImageService;
import com.example.dalathasfarm.utils.FileUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("${api.prefix}/product-images")
@RequiredArgsConstructor
public class ProductImageController {
    private final IProductImageService productImageService;

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<ResponseObject> delete(@PathVariable Integer id) throws DataNotFoundException, Exception {
        ProductImage productImage = productImageService.deleteProductImageById(id);
        if (productImage != null) {
            FileUtils.deleteFile(productImage.getUrl());
        }
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Delete product image successfully")
                .status(HttpStatus.OK)
                .data(productImage)
                .build());
    }
}
