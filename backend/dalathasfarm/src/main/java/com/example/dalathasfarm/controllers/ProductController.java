package com.example.dalathasfarm.controllers;

import com.example.dalathasfarm.components.LocalizationUtils;
import com.example.dalathasfarm.components.SecurityUtils;
import com.example.dalathasfarm.dtos.ProductDto;
import com.example.dalathasfarm.dtos.ProductImageDto;
import com.example.dalathasfarm.models.Product;
import com.example.dalathasfarm.models.ProductImage;
import com.example.dalathasfarm.responses.ResponseObject;
import com.example.dalathasfarm.responses.product.ProductListResponse;
import com.example.dalathasfarm.responses.product.ProductResponse;
import com.example.dalathasfarm.responses.productimage.ProductImageResponse;
import com.example.dalathasfarm.services.Product.IProductService;
import com.example.dalathasfarm.services.ProductImage.IProductImageService;
import com.example.dalathasfarm.utils.MessageKeys;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.UrlResource;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.util.StringUtils;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("${api.prefix}/products")
@RequiredArgsConstructor
public class ProductController {
    private final IProductService productService;
    private final IProductImageService productImageService;
    private final LocalizationUtils localizationUtils;
    private final SecurityUtils securityUtils;

    private static final Logger logger = LoggerFactory.getLogger(ProductController.class);


    // Create thông tin sản phẩm
    @PostMapping("")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<ResponseObject> createProduct(
            @Valid @RequestBody ProductDto productDto,
            BindingResult result) throws Exception {
        if (result.hasErrors()) {
            List<String> errorMessage = result.getFieldErrors()
                    .stream()
                    .map(FieldError::getDefaultMessage)
                    .toList();
            return ResponseEntity.badRequest().body(ResponseObject.builder()
                    .message(String.join("; ", errorMessage))
                    .status(HttpStatus.BAD_REQUEST)
                    .data(null)
                    .build());
        }

        Product newProduct = productService.createProduct(productDto);
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Create product successfully")
                .status(HttpStatus.OK)
                .data(newProduct)
                .build());
    }

    // Upload ảnh
    @PostMapping(value = "uploads/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<ResponseObject> uploadImages(
            @PathVariable int id,
            @RequestParam("files") List<MultipartFile> files
    ) throws Exception {
        Product product = productService.getProductById(id);

        if (files == null) {
            files = new ArrayList<MultipartFile>();
        }
        if (files.size() > ProductImage.MAXIMUM_IMAGES_PER_PRODUCT) {
            return ResponseEntity.badRequest().body(ResponseObject.builder()
                    .message(localizationUtils.getLocalizedMessage(MessageKeys.UPLOAD_IMAGES_MAX_5))
                    .status(HttpStatus.BAD_REQUEST)
                    .data(null)
                    .build());
        }

        List<ProductImageDto> productImageDtos = new ArrayList<>();
        for (MultipartFile file : files) {
            if (file.getSize() == 0) continue;

            if (file.getSize() > 10 * 1024 * 1024) {
                return ResponseEntity.status(HttpStatus.PAYLOAD_TOO_LARGE)
                        .body(ResponseObject.builder()
                                .message(localizationUtils.getLocalizedMessage(MessageKeys.UPLOAD_IMAGES_FILE_LARGE))
                                .status(HttpStatus.BAD_REQUEST)
                                .data(null)
                                .build());
            }

            String contentType = file.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                return ResponseEntity.status(HttpStatus.UNSUPPORTED_MEDIA_TYPE).body(
                        ResponseObject.builder()
                                .message(localizationUtils.getLocalizedMessage(MessageKeys.UPLOAD_IMAGES_FILE_MUST_BE_IMAGE))
                                .status(HttpStatus.BAD_REQUEST)
                                .data(null)
                                .build());
            }

            // Lưu file
            String filename = storeFile(file);

            // Lưu vào hình ảnh vào bảng product_image trong DataBase
            ProductImageDto newProductImageDto = ProductImageDto.builder()
                    .productId(product.getId())
                    .name(filename)
                    .build();
            productService.createProductImage(newProductImageDto);
            productImageDtos.add(newProductImageDto);
        }
        return ResponseEntity.ok().body(ResponseObject.builder()
                .message("Upload image successfully")
                .status(HttpStatus.CREATED)
                .data(productImageDtos)
                .build());
    }

    @GetMapping("/images/{imageName}")
    public ResponseEntity<?> viewImage(@PathVariable String imageName) {
        try {
            Path imagePath = Paths.get("uploads/" + imageName);
            UrlResource resource = new UrlResource(imagePath.toUri());

            if (resource.exists()) {
                return ResponseEntity.ok()
                        .contentType(MediaType.IMAGE_JPEG)
                        .body(resource);
            } else {
                return ResponseEntity.ok()
                        .contentType(MediaType.IMAGE_JPEG)
                        .body(new UrlResource(Paths.get("uploads/notfound.jpg").toUri()));
                //return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    private String storeFile(MultipartFile file) throws IOException {
        if (!isImageFile(file) && file.getOriginalFilename() != null) throw new RuntimeException("Khong phai file anh");

        String filename = StringUtils.cleanPath(Objects.requireNonNull(file.getOriginalFilename()));
        String uniqueFilename = UUID.randomUUID().toString() + "_" + filename;
        Path uploadDir = Paths.get("uploads");
        if (!Files.exists(uploadDir)) {
            Files.createDirectories(uploadDir);
        }

        Path destination = Paths.get(uploadDir.toString(), uniqueFilename);
        Files.copy(file.getInputStream(), destination, StandardCopyOption.REPLACE_EXISTING);
        return uniqueFilename;
    }

    // Hàm kiểm tra xem upload file ảnh có phải là file ảnh không
    private boolean isImageFile(MultipartFile file) {
        String contentType = file.getContentType();
        return contentType != null && contentType.startsWith("image/");
    }

    // Fake sản phẩm
//    @PostMapping("/generateFakeSanPhams")
//    @PreAuthorize("hasRole('ROLE_ADMIN')")
//    public ResponseEntity<String> generateFakeSanPhams() {
//        Faker faker = new Faker();
//        for (int i = 0; i < 200; i++) {
//            String tenSanPham = faker.commerce().productName();
//            if (sanPhamService.existsByTENSANPHAM(tenSanPham)) continue;
//
//            SanPhamDTO newSanPhamDTO = SanPhamDTO
//                    .builder()
//                    .TENSANPHAM(tenSanPham)
//                    .GIA(BigDecimal.valueOf(faker.number().numberBetween(10L, 9000)))
//                    .MATHUONGHIEU(faker.number().numberBetween(1, 5))
//                    .MOTA(faker.lorem().sentence())
//                    .SOLUONGTONKHO(faker.number().numberBetween(1, 10000))
//                    .MALOAISANPHAM(faker.number().numberBetween(1, 5))
//                    .build();
//
//            try {
//                sanPhamService.createSanPham(newSanPhamDTO);
//            } catch (Exception e) {
//                return ResponseEntity.badRequest().body(e.getMessage());
//            }
//        }
//        return ResponseEntity.ok("Fake SanPhams thanh cong!!!");
//    }

    @GetMapping("")
    public ResponseEntity<ResponseObject> getAllProduct(
            @RequestParam(defaultValue = "") String keyword,
            @RequestParam(defaultValue = "0", name = "categoryId") int categoryId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int limit
    ) throws Exception {
        // Tạo Pageable từ thông tin trang và giới hạn
        PageRequest pageRequest = PageRequest.of(
                page, limit,
                //Sort.by("NGAYTAO").descending()
                Sort.by("id").ascending()
        );
        logger.info(String.format("keyword = %s, categoryId = %d, page = %d, limit = %d",
                keyword, categoryId, page, limit));

        Page<ProductResponse> productResponsePage = productService.getAllProduct(keyword, categoryId, pageRequest);

        // Lấy tổng số trang
        int totalPages = productResponsePage.getTotalPages();
        List<ProductResponse> productResponses  = productResponsePage.getContent();

        ProductListResponse productListResponse = ProductListResponse.builder()
                .productResponses(productResponses)
                .totalPages(totalPages)
                .build();

        return ResponseEntity.ok(ResponseObject.builder()
                .message("Get products successfully")
                .status(HttpStatus.OK)
                .data(productListResponse)
                .build());
    }

//    // getAllSanPham old
//    @GetMapping("")
//    public ResponseEntity<SanPhamListResponse> getAllSanPham(
//            @RequestParam(defaultValue = "") String keyword,
//            @RequestParam(defaultValue = "0", name = "MALOAISANPHAM") int MALOAISANPHAM,
//            @RequestParam(defaultValue = "0") int page,
//            @RequestParam(defaultValue = "0") int limit
//    ) {
//        // Tạo Pageable từ thông tin trang và giới hạn
//        PageRequest pageRequest = PageRequest.of(
//                page, limit,
//                //Sort.by("NGAYTAO").descending()
//                Sort.by("MASANPHAM").ascending()
//        );
//        Page<SanPhamResponse> sanPhamResponses = sanPhamService.getAllSanPham(keyword, MALOAISANPHAM, pageRequest);
//
//        // Lấy tổng số trang
//        int tongSoTrang = sanPhamResponses.getTotalPages();
//        List<SanPhamResponse> dsSanPham = sanPhamResponses.getContent();
//
//        SanPhamListResponse newSanPhamListResponse = SanPhamListResponse
//                .builder()
//                .sanPhamResponseList(dsSanPham)
//                .tongSoTrang(tongSoTrang)
//                .build();
//
//        return ResponseEntity.ok(newSanPhamListResponse);
//    }

    @GetMapping("/{id}")
    public ResponseEntity<ResponseObject> getProductById(@PathVariable Integer id) throws Exception{
        Product product = productService.getProductById(id);
        List<ProductImageResponse> productImageResponses = productImageService.getAllProductImageByProduct(product);
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Get detail product successfully")
                .status(HttpStatus.OK)
                .data(ProductResponse.fromProductForDetail(product,productImageResponses))
                .build());

    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<ResponseObject> updateProduct(
            @PathVariable Integer id,
            @Valid @RequestBody ProductDto productDto
    ) throws Exception{
        Product product = productService.updateProduct(id,productDto);
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Update product successfully")
                .status(HttpStatus.OK)
                .data(product)
                .build());

    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<ResponseObject> deleteProduct(@PathVariable Integer id) {
        productService.deleteProduct(id);
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Product with id = " + id + " deleted successfully")
                .status(HttpStatus.OK)
                .data(null)
                .build());
    }

    @GetMapping("/by-ids")
    public ResponseEntity<ResponseObject> getProductByIds(@RequestParam("ids") String ids) {
        // eg: 1,3,4,5,7,9
        // Tách chuỗi ids thành một mảng các số nguyên
        List<Integer> productIdList = Arrays.stream(ids.split(","))
                .map(Integer::parseInt)
                .collect(Collectors.toList());
        List<Product> products = productService.findProductByIdList(productIdList);
        List<ProductResponse> productResponses = products.stream()
                .map(ProductResponse::fromProduct)
                .collect(Collectors.toList());
        ProductListResponse productListResponse = ProductListResponse.builder()
                .productResponses(productResponses)
                .totalPages(0)
                .build();

        return ResponseEntity.ok(ResponseObject.builder()
                .message("Get products successfully")
                .status(HttpStatus.OK)
                .data(productListResponse)
                .build());

    }

//    @PostMapping("/like/{productId}")
//    @PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_USER')")
//    public ResponseEntity<ResponseObject> likeProduct(@PathVariable int productId) throws Exception {
//        Account loginUser = securityUtils.getLoggedInUser();
//        SanPham likedProduct = sanPhamService.likeProduct(loginUser.getUSERID(), productId);
//        return ResponseEntity.ok(ResponseObject.builder()
//                .data(SanPhamResponse.fromSanPham(likedProduct))
//                .message("Like product successfully")
//                .status(HttpStatus.OK)
//                .build());
//    }
//
//    @PostMapping("/unlike/{productId}")
//    @PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_USER')")
//    public ResponseEntity<ResponseObject> unlikeProduct(@PathVariable int productId) throws Exception {
//        Account loginUser = securityUtils.getLoggedInUser();
//        SanPham unlikedProduct = sanPhamService.unlikeProduct(loginUser.getUSERID(), productId);
//        return ResponseEntity.ok(ResponseObject.builder()
//                .data(SanPhamResponse.fromSanPham(unlikedProduct))
//                .message("Unlike product successfully")
//                .status(HttpStatus.OK)
//                .build());
//    }
//
//    @PostMapping("/favorite-products")
//    @PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_USER')")
//    public ResponseEntity<ResponseObject> findFavoriteProductsByUserId() throws Exception {
//        Account loginUser = securityUtils.getLoggedInUser();
//        List<SanPhamResponse> favoriteProducts = sanPhamService.findFavoriteProductsByUserId(loginUser.getUSERID());
//        return ResponseEntity.ok(ResponseObject.builder()
//                .data(favoriteProducts)
//                .message("Favorite products retrieved successfully")
//                .status(HttpStatus.OK)
//                .build());
//    }
//
//    @PostMapping("/generateFakeLikes")
//    @PreAuthorize("hasRole('ROLE_ADMIN')")
//    public ResponseEntity<ResponseObject> generateFakeLikes() throws Exception {
//        sanPhamService.generateFakeLikes();
//        return ResponseEntity.ok(ResponseObject.builder()
//                .message("Insert fake likes succcessfully")
//                .data(null)
//                .status(HttpStatus.OK)
//                .build());
//    }
}
