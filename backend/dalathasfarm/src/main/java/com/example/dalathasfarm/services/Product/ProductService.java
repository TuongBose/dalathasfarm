package com.example.dalathasfarm.services.Product;

import com.example.dalathasfarm.dtos.ProductDto;
import com.example.dalathasfarm.dtos.ProductImageDto;
import com.example.dalathasfarm.exceptions.DataNotFoundException;
import com.example.dalathasfarm.exceptions.InvalidParamException;
import com.example.dalathasfarm.models.Category;
import com.example.dalathasfarm.models.Occasion;
import com.example.dalathasfarm.models.Product;
import com.example.dalathasfarm.models.ProductImage;
import com.example.dalathasfarm.repositories.*;
import com.example.dalathasfarm.responses.product.ProductResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ProductService implements IProductService{
    private final ProductRepository productRepository;
    private final OccasionRepository occasionRepository;
    private final CategoryRepository categoryRepository;
    private final ProductImageRepository productImageRepository;
    private final UserRepository userRepository;

    @Override
    public Product createProduct(ProductDto productDto) throws Exception {
        Category existingCategory = categoryRepository.findById(productDto.getCategoryId())
                .orElseThrow(() -> new DataNotFoundException("Cannot find Category"));

        Occasion existingOccasion = occasionRepository.findById(productDto.getOccasionId())
                .orElseThrow(() -> new DataNotFoundException("Cannot find Occasion"));

        Product newProduct = Product.builder()
                .name(productDto.getName())
                .price(productDto.getPrice())
                .category(existingCategory)
                .occasion(existingOccasion)
                .description(productDto.getDescription())
                .stockQuantity(productDto.getStockQuantity())
                .thumbnail(productDto.getThumbnail())
                .build();
        return productRepository.save(newProduct);
    }

    @Override
    public Product getProductById(Integer id) throws Exception{
        return productRepository.findById(id)
                .orElseThrow(() -> new DataNotFoundException("Cannot find Product"));
    }

    @Override
    public Page<ProductResponse> getAllProduct(String keyword, Integer categoryId, PageRequest pageRequest) throws Exception{
        // Lấy danh sách sản phẩm theo trang(page) và giới hạn(limit)
        Page<Product> products = productRepository.searchProducts(categoryId, keyword, pageRequest);

        return products.map(ProductResponse::fromProduct);
    }

    @Override
    public Product updateProduct(Integer id, ProductDto productDto) throws Exception {
        Product existingProduct = productRepository.findById(id)
                .orElseThrow(() -> new DataNotFoundException("Cannot find Product"));

        Category existingCategory = categoryRepository.findById(productDto.getCategoryId())
                .orElseThrow(() -> new DataNotFoundException("Cannot find Category"));

        Occasion existingOccasion = occasionRepository.findById(productDto.getOccasionId())
                .orElseThrow(() -> new DataNotFoundException("Cannot find Occasion"));

        if (productDto.getName() != null && !productDto.getName().isEmpty()) {
            existingProduct.setName(productDto.getName());
        }

        existingProduct.setCategory(existingCategory);
        existingProduct.setOccasion(existingOccasion);

        if (productDto.getStockQuantity() >= 0) {
            existingProduct.setStockQuantity(productDto.getStockQuantity());
        }

        if (productDto.getPrice() != null && productDto.getPrice().compareTo(BigDecimal.ZERO) >= 0) {
            existingProduct.setPrice(productDto.getPrice());
        }

        if (productDto.getDescription() != null && !productDto.getDescription().isEmpty()) {
            existingProduct.setDescription(productDto.getDescription());
        }

        if (productDto.getThumbnail() != null && !productDto.getThumbnail().isEmpty()) {
            existingProduct.setThumbnail(productDto.getThumbnail());
        }

        return productRepository.save(existingProduct);
    }

    @Override
    public void deleteProduct(Integer id) {
        Optional<Product> optionalProduct = productRepository.findById(id);
        optionalProduct.ifPresent(productRepository::delete);
    }

    @Override
    public boolean existsByName(String name) {
        return productRepository.existsByName(name);
    }

    @Override
    public ProductImage createProductImage(ProductImageDto productImageDto) throws Exception {
        Product existingProduct = getProductById(productImageDto.getProductId());

        ProductImage newProductImage = ProductImage.builder()
                .name(productImageDto.getName())
                .product(existingProduct)
                .build();

        // Không cho thêm quá 5 ảnh cho 1 sản phẩm
        int size = productImageRepository.findByProduct(existingProduct).size();
        if (size >= ProductImage.MAXIMUM_IMAGES_PER_PRODUCT)
            throw new InvalidParamException("Number of images must be <= "+ProductImage.MAXIMUM_IMAGES_PER_PRODUCT);

        if(existingProduct.getThumbnail()==null){
            existingProduct.setThumbnail(newProductImage.getName());
        }
        productRepository.save(existingProduct);
        productImageRepository.save(newProductImage);
        return newProductImage;
    }

    @Override
    public List<Product> findProductByIdList(List<Integer> ids) {
        return productRepository.findProductByProductIds(ids);
    }
}
