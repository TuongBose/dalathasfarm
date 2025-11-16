package com.example.dalathasfarm.controllers;

import com.example.dalathasfarm.components.LocalizationUtils;
import com.example.dalathasfarm.components.SecurityUtils;
import com.example.dalathasfarm.dtos.RefreshTokenDTO;
import com.example.dalathasfarm.dtos.UpdateUserDto;
import com.example.dalathasfarm.dtos.UserDto;
import com.example.dalathasfarm.dtos.UserLoginDto;
import com.example.dalathasfarm.exceptions.DataNotFoundException;
import com.example.dalathasfarm.exceptions.InvalidPasswordException;
import com.example.dalathasfarm.models.Token;
import com.example.dalathasfarm.models.User;
import com.example.dalathasfarm.responses.ResponseObject;
import com.example.dalathasfarm.responses.user.UserListResponse;
import com.example.dalathasfarm.responses.user.UserResponse;
import com.example.dalathasfarm.responses.user.LoginResponse;
import com.example.dalathasfarm.responses.user.RegisterResponse;
import com.example.dalathasfarm.services.Token.ITokenService;
import com.example.dalathasfarm.services.User.IUserService;
import com.example.dalathasfarm.utils.FileUtils;
import com.example.dalathasfarm.utils.MessageKeys;
import com.example.dalathasfarm.utils.ValidationUtils;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.UrlResource;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.util.StringUtils;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.nio.file.Paths;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("${api.prefix}/users")
@RequiredArgsConstructor
public class UserController {
    private final IUserService userService;
    private final LocalizationUtils localizationUtils;
    private final ITokenService tokenService;
    private final SecurityUtils securityUtils;

    private boolean isMobileDevice(String userAgent) {
        // Kiem tra User-Agent header de xac dinh thiet bi di dong
        return userAgent.toLowerCase().contains("mobile");
    }

    @PostMapping("/register")
    public ResponseEntity<ResponseObject> createUser(
            @Valid @RequestBody UserDto userDto,
            BindingResult result
    ) throws Exception {
        RegisterResponse registerResponse = new RegisterResponse();

        if (result.hasErrors()) {
            List<String> errorMessages = result.getFieldErrors().stream().map(FieldError::getDefaultMessage).toList();
            registerResponse.setMessage(String.join("; ", errorMessages));
            return ResponseEntity.badRequest().body(ResponseObject.builder()
                    .message(String.join("; ", errorMessages))
                    .status(HttpStatus.BAD_REQUEST)
                    .data(registerResponse)
                    .build());
        }


        if (userDto.getPhoneNumber() == null || userDto.getPhoneNumber().isBlank()) {
            return ResponseEntity.badRequest().body(ResponseObject.builder()
                    .message("At least phone number is required")
                    .status(HttpStatus.BAD_REQUEST)
                    .data(null)
                    .build());
        } else {
            if (!ValidationUtils.isValidPhoneNumber(userDto.getPhoneNumber())) {
                throw new Exception("Invalid phone number");
            }
        }


        if (!userDto.getPassword().equals(userDto.getRetypePassword())) {
            registerResponse.setMessage(localizationUtils.getLocalizedMessage(MessageKeys.PASSWORD_NOT_MATCH));
            return ResponseEntity.badRequest().body(ResponseObject.builder()
                    .message(registerResponse.getMessage())
                    .status(HttpStatus.BAD_REQUEST)
                    .data(registerResponse)
                    .build());
        }

        User newUser = userService.createUser(userDto);
        registerResponse.setMessage("Signing up successfully");
        registerResponse.setUser(UserResponse.fromUser(newUser));
        return ResponseEntity.ok(ResponseObject.builder()
                .message(registerResponse.getMessage())
                .status(HttpStatus.CREATED)
                .data(registerResponse)
                .build());
    }

    @PostMapping("/register/admin")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<ResponseObject> createUserAdmin(
            @Valid @RequestBody UserDto userDto,
            BindingResult result
    ) throws Exception {
        if (result.hasErrors()) {
            List<String> errorMessages = result.getFieldErrors()
                    .stream()
                    .map(FieldError::getDefaultMessage)
                    .toList();

            return ResponseEntity.badRequest().body(ResponseObject.builder()
                    .message(errorMessages.toString())
                    .status(HttpStatus.BAD_REQUEST)
                    .data(null)
                    .build());
        }

        if (userDto.getPhoneNumber() == null || userDto.getPhoneNumber().isBlank()) {
            return ResponseEntity.badRequest().body(ResponseObject.builder()
                    .status(HttpStatus.BAD_REQUEST)
                    .data(null)
                    .message("At least phone number is required")
                    .build());
        } else {
            //phone number not blank
            if (!ValidationUtils.isValidPhoneNumber(userDto.getPhoneNumber())) {
                throw new Exception("Invalid phone number");
            }
        }

        if (!userDto.getPassword().equals(userDto.getRetypePassword())) {
            return ResponseEntity.badRequest().body(ResponseObject.builder()
                    .message(localizationUtils.getLocalizedMessage(MessageKeys.PASSWORD_NOT_MATCH))
                    .status(HttpStatus.BAD_REQUEST)
                    .data(null)
                    .build());
        }

        User user = userService.createUserAdmin(userDto);
        return ResponseEntity.ok(ResponseObject.builder()
                .status(HttpStatus.CREATED)
                .data(UserResponse.fromUser(user))
                .message("User registration successful")
                .build());
    }


    @PostMapping("/login")
    public ResponseEntity<ResponseObject> login(
            @Valid @RequestBody UserLoginDto userLoginDto,
            BindingResult result,
            HttpServletRequest request
    ) throws Exception {
        LoginResponse loginResponse = new LoginResponse();

        if (result.hasErrors()) {
            List<String> errorMessages = result.getFieldErrors().stream().map(FieldError::getDefaultMessage).toList();
            loginResponse.setMessage(String.join("; ", errorMessages));
            return ResponseEntity.badRequest().body(ResponseObject.builder()
                    .message(String.join("; ", errorMessages))
                    .status(HttpStatus.BAD_REQUEST)
                    .data(loginResponse)
                    .build());
        }

        if (userLoginDto.getPhoneNumber() == null || userLoginDto.getPhoneNumber().isBlank()) {
            return ResponseEntity.badRequest().body(ResponseObject.builder()
                    .message("At least email or phone number is required")
                    .status(HttpStatus.BAD_REQUEST)
                    .data(null)
                    .build());
        } else {
            if (!ValidationUtils.isValidPhoneNumber(userLoginDto.getPhoneNumber())) {
                throw new Exception("Invalid phone number");
            }
        }

        // Kiểm tra thông tin đăng nhập và sinh token
        String token = userService.login(userLoginDto);
        String userAgent = request.getHeader("User-Agent");
        User userDetail = userService.getUserDetailsFromToken(token);
        Token jwtToken = tokenService.addToken(userDetail, token, isMobileDevice(userAgent));

//        LoginResponse loginResponse = LoginResponse.builder()
        loginResponse.setMessage(localizationUtils.getLocalizedMessage(MessageKeys.LOGIN_SUCCESSFULLY));
        loginResponse.setToken(token);
        loginResponse.setTokenType(jwtToken.getTokenType());
        loginResponse.setRefreshToken(jwtToken.getRefreshToken());
        loginResponse.setUserName(userDetail.getFullName());
        loginResponse.setRole(userDetail.getAuthorities().stream().map(GrantedAuthority::getAuthority).toList());
        loginResponse.setId(userDetail.getId());

        return ResponseEntity.ok().body(ResponseObject.builder()
                .message(loginResponse.getMessage())
                .status(HttpStatus.OK)
                .data(loginResponse)
                .build());
    }

    @PostMapping("/refreshToken")
    public ResponseEntity<ResponseObject> refreshToken(@Valid @RequestBody RefreshTokenDTO refreshTokenDTO) throws Exception {
        User userDetail = userService.getUserDetailsFromRefreshToken(refreshTokenDTO.getRefreshToken());
        Token jwtToken = tokenService.refreshToken(refreshTokenDTO.getRefreshToken(), userDetail);
        LoginResponse loginResponse = LoginResponse.builder()
                .message("Refresh token successfully")
                .token(jwtToken.getToken())
                .tokenType(jwtToken.getTokenType())
                .refreshToken(jwtToken.getRefreshToken())
                .userName(userDetail.getFullName())
                .role(userDetail.getAuthorities().stream().map(GrantedAuthority::getAuthority).toList())
                .id(userDetail.getId())
                .build();
        return ResponseEntity.ok().body(ResponseObject.builder()
                .message(loginResponse.getMessage())
                .status(HttpStatus.OK)
                .data(loginResponse)
                .build());
    }

    @PostMapping("/details")
    @PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_CUSTOMER') or hasRole('ROLE_EMPLOYEE')")
    public ResponseEntity<ResponseObject> getUserDetails(
            @RequestHeader("Authorization") String authorizationHeader
    ) throws Exception {
        String extractedToken = authorizationHeader.substring(7); // Loại bỏ "Bearer " từ chuỗi token
        User user = userService.getUserDetailsFromToken(extractedToken);
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Get user's detail successfully")
                .status(HttpStatus.OK)
                .data(UserResponse.fromUser(user))
                .build());
    }

    @PutMapping("/details/{userId}")
    @PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_USER')")
    public ResponseEntity<ResponseObject> updateUserDetails(
            @RequestHeader("Authorization") String authorizationHeader,
            @PathVariable int userId,
            @RequestBody UpdateUserDto updateUserDto
    ) throws Exception {
        String extractedToken = authorizationHeader.substring(7); // Loại bỏ "Bearer " từ chuỗi token
        User user = userService.getUserDetailsFromToken(extractedToken);

        // Đảm bảo rằng user gọi request chứa token phải trùng với user muốn update
        if (user.getId() != userId) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        User updateUser = userService.updateUser(updateUserDto, userId);
        return ResponseEntity.ok().body(ResponseObject.builder()
                .message("Update user detail successfully")
                .status(HttpStatus.OK)
                .data(UserResponse.fromUser(updateUser))
                .build());
    }

    @GetMapping("")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<ResponseObject> getAllUserCustomer(
            @RequestParam(defaultValue = "", required = false) String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int limit
    ) throws Exception {
        PageRequest pageRequest = PageRequest.of(
                page, limit,
                Sort.by("id").ascending()
        );
        Page<UserResponse> userPage = userService.getAllUserCustomer(keyword, pageRequest)
                .map(UserResponse::fromUser);

        // Lay tong so trang
        int totalPages = userPage.getTotalPages();
        List<UserResponse> userResponses = userPage.getContent();
        UserListResponse userListResponse = UserListResponse
                .builder()
                .userResponseList(userResponses)
                .totalPages(totalPages)
                .build();
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Get list of User customer successfully")
                .status(HttpStatus.OK)
                .data(userListResponse)
                .build());
    }

    @PutMapping("/reset-password/{userId}")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<ResponseObject> resetPassword(@Valid @PathVariable int userId) {
        try {
            String newPassword = UUID.randomUUID().toString().substring(0, 5); // Create new password
            userService.resetPassword(userId, newPassword);
            return ResponseEntity.ok(ResponseObject.builder()
                    .message("Reset password successfully")
                    .status(HttpStatus.OK)
                    .data(newPassword)
                    .build());
        } catch (InvalidPasswordException e) {
            return ResponseEntity.badRequest().body(ResponseObject.builder()
                    .message("Invalid password: " + e.getMessage())
                    .status(HttpStatus.BAD_REQUEST)
                    .data(null)
                    .build());
        } catch (DataNotFoundException e) {
            return ResponseEntity.badRequest().body(ResponseObject.builder()
                    .message("User not found: " + e.getMessage())
                    .status(HttpStatus.BAD_REQUEST)
                    .data(null)
                    .build());
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ResponseObject.builder()
                    .message(e.getMessage())
                    .status(HttpStatus.BAD_REQUEST)
                    .data(null)
                    .build());
        }
    }

    @PutMapping("/block/{userId}/{active}")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<ResponseObject> blockOrEnable(
            @Valid @PathVariable int userId,
            @Valid @PathVariable int active
    ) throws Exception {
        userService.blockOrEnable(userId, active > 0);
        String message = active > 0 ? "Successfully enable the user." : "Successfully blocked the user.";
        return ResponseEntity.ok().body(ResponseObject.builder()
                .message(message)
                .status(HttpStatus.OK)
                .data(null)
                .build());

    }

    @PostMapping(value = "/upload-profile-image", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasRole('ROLE_USER') or hasRole('ROLE_ADMIN')")
    public ResponseEntity<ResponseObject> uploadProfileImage(
            @RequestParam("file") MultipartFile file
    ) throws Exception {
        User loginUser = securityUtils.getLoggedInUser();
        if (file == null || file.isEmpty()) {
            return ResponseEntity.badRequest().body(ResponseObject.builder()
                    .message("Image file is required.")
                    .status(HttpStatus.NOT_FOUND)
                    .data(null)
                    .build()
            );
        }

        if (file.getSize() > 10 * 1024 * 1024) { // 10MB
            return ResponseEntity.status(HttpStatus.PAYLOAD_TOO_LARGE)
                    .body(ResponseObject.builder()
                            .message("Image file size exceeds the allowed limit of 10MB.")
                            .status(HttpStatus.PAYLOAD_TOO_LARGE)
                            .data(null)
                            .build());
        }

        // Check file type
        if (!FileUtils.isImageFile(file)) {
            return ResponseEntity.status(HttpStatus.UNSUPPORTED_MEDIA_TYPE)
                    .body(ResponseObject.builder()
                            .message("Uploaded file must be an image.")
                            .status(HttpStatus.UNSUPPORTED_MEDIA_TYPE)
                            .data(null)
                            .build());
        }

        // Store file and get filename
        String oldFileName = loginUser.getProfileImage();
        String imageName = FileUtils.storeFile(file);

        userService.changeProfileImage(loginUser.getId(), imageName);
        // Delete old file if exists
        if (!StringUtils.isEmpty(oldFileName)) {
            FileUtils.deleteFile(oldFileName);
        }
//1aba82e1-4599-4c8b-8ec5-9c16e5aad379_3734888057500.png
        return ResponseEntity.ok().body(ResponseObject.builder()
                .message("Upload profile image successfully")
                .status(HttpStatus.CREATED)
                .data(imageName) // Return the filename or image URL
                .build());
    }

    @GetMapping("/profile-images/{imageName}")
    public ResponseEntity<?> viewImage(@PathVariable String imageName) {
        try {
            java.nio.file.Path imagePath = Paths.get("uploads/" + imageName);
            UrlResource resource = new UrlResource(imagePath.toUri());

            if (resource.exists()) {
                return ResponseEntity.ok()
                        .contentType(MediaType.IMAGE_JPEG)
                        .body(resource);
            } else {
                return ResponseEntity.ok()
                        .contentType(MediaType.IMAGE_JPEG)
                        .body(new UrlResource(Paths.get("uploads/default-profile-image.jpeg").toUri()));
                //return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }
}
