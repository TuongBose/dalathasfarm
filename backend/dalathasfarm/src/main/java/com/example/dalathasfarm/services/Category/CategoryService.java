package com.example.dalathasfarm.services.Category;

import com.example.dalathasfarm.dtos.CategoryDto;
import com.example.dalathasfarm.exceptions.DataNotFoundException;
import com.example.dalathasfarm.models.Category;
import com.example.dalathasfarm.models.Product;
import com.example.dalathasfarm.repositories.CategoryRepository;
import com.example.dalathasfarm.repositories.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.crossstore.ChangeSetPersister;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CategoryService implements ICategoryService{
    private final CategoryRepository categoryRepository;
    private final ProductRepository productRepository;

    @Override
    public Category getCategoryById(Integer id) throws Exception {
        return categoryRepository.findById(id)
                .orElseThrow(()->new DataNotFoundException("Category not found"));
    }

    @Override
    public List<Category> getAllCategory() {
        return categoryRepository.findAll();
    }

    @Override
    public Category deleteCategory(Integer id) throws Exception {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new ChangeSetPersister.NotFoundException());

        List<Product> products = productRepository.findByCategory(category);
        if (!products.isEmpty()) {
            throw new IllegalStateException("Cannot delete category with associated products");
        } else {
            categoryRepository.deleteById(id);
            return category;
        }
    }

    @Override
    public Category updateCategory(Integer id, CategoryDto categoryDto) throws Exception {
        Category existingCategory = getCategoryById(id);
        if(!categoryRepository.existsByName(categoryDto.getName())) {
            existingCategory.setName(categoryDto.getName());
            categoryRepository.save(existingCategory);
            return existingCategory;
        }else {
            throw new Exception("Category already exist");
        }
    }

    @Override
    @Transactional
    public Category createCategory(CategoryDto categoryDto) throws Exception {
        if(!categoryRepository.existsByName(categoryDto.getName())) {
            Category newCategory = Category
                    .builder()
                    .name(categoryDto.getName())
                    .build();
            return categoryRepository.save(newCategory);
        }
        else {
            throw new Exception("Category already exist");
        }
    }
}
