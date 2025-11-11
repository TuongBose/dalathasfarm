package com.example.dalathasfarm.services.Category;

import com.example.dalathasfarm.dtos.CategoryDto;
import com.example.dalathasfarm.models.Category;

import java.util.List;

public interface ICategoryService {
    Category getCategoryById(Integer id) throws  Exception;
    List<Category> getAllCategory();
    Category deleteCategory(Integer id) throws  Exception;
    Category updateCategory(Integer id, CategoryDto categoryDto) throws  Exception;
    Category createCategory(CategoryDto categoryDto) throws  Exception;
}
