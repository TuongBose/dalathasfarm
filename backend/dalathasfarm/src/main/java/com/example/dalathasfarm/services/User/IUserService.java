package com.example.dalathasfarm.services.User;


import com.example.dalathasfarm.dtos.ChangePasswordDto;
import com.example.dalathasfarm.dtos.UpdateUserDto;
import com.example.dalathasfarm.dtos.UserDto;
import com.example.dalathasfarm.dtos.UserLoginDto;
import com.example.dalathasfarm.exceptions.DataNotFoundException;
import com.example.dalathasfarm.exceptions.InvalidPasswordException;
import com.example.dalathasfarm.models.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface IUserService {
    User createUser(UserDto userDto) throws Exception;
    User createUserEmployee(UserDto userDto) throws Exception;
    User createUserAdmin(UserDto userDto) throws Exception;
    //String login(String EMAIL, String SODIENTHOAI, String PASSWORD, Integer roleId) throws Exception;
    String login(UserLoginDto userLoginDto) throws Exception;
    User getUserDetailsFromToken(String token) throws Exception;
    User getUserDetailsFromRefreshToken(String refreshToken) throws Exception;
    User updateUser(UpdateUserDto updateUserDto, int userId) throws Exception;
    Page<User> getAllUserCustomer(String keyword, Pageable pageable) throws Exception;
    Page<User> getAllUserEmployee(String keyword, Pageable pageable) throws Exception;
    Page<User> getAllUserAdmin(String keyword, Pageable pageable) throws Exception;
    void resetPassword(int userId, String newPassword) throws DataNotFoundException, InvalidPasswordException;
    void blockOrEnable(int userId, boolean active) throws DataNotFoundException;
    void changeProfileImage(int userId, String imageName) throws Exception;
    User getUserByEmail(String email) throws Exception;
    void changePassword(int userId, ChangePasswordDto changePasswordDto) throws Exception;
}
