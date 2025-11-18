package com.example.dalathasfarm.services.User;

import com.example.dalathasfarm.components.JwtTokenUtils;
import com.example.dalathasfarm.components.LocalizationUtils;
import com.example.dalathasfarm.dtos.UpdateUserDto;
import com.example.dalathasfarm.dtos.UserDto;
import com.example.dalathasfarm.dtos.UserLoginDto;
import com.example.dalathasfarm.exceptions.DataNotFoundException;
import com.example.dalathasfarm.exceptions.InvalidPasswordException;
import com.example.dalathasfarm.models.Role;
import com.example.dalathasfarm.models.Token;
import com.example.dalathasfarm.models.User;
import com.example.dalathasfarm.repositories.RoleRepository;
import com.example.dalathasfarm.repositories.TokenRepository;
import com.example.dalathasfarm.repositories.UserRepository;
import com.example.dalathasfarm.utils.MessageKeys;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.Optional;

@RequiredArgsConstructor
@Service
public class UserService implements IUserService {
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenUtils jwtTokenUtils;
    private final AuthenticationManager authenticationManager;
    private final TokenRepository tokenRepository;
    private final LocalizationUtils localizationUtils;

    @Override
    public User createUser(UserDto userDto) throws Exception {
        if (userDto.getPhoneNumber() != null && !userDto.getPhoneNumber().trim().isBlank() &&
                userRepository.existsByPhoneNumber(userDto.getPhoneNumber()))
            throw new DataIntegrityViolationException("Phone number already exists");

        if (userDto.getEmail() != null && !userDto.getEmail().trim().isBlank() &&
                userRepository.existsByEmail(userDto.getEmail()))
            throw new DataIntegrityViolationException("Email already exists");

        Role roleCustomer = roleRepository.findById(Role.CUSTOMER)
                .orElseThrow(() -> new DataNotFoundException("Role Customer does not exists"));

        User newUser = User.builder()
                .fullName(userDto.getFullName())
                .password(userDto.getPassword())
                .address(userDto.getAddress())
                .dateOfBirth(userDto.getDateOfBirth())
                .profileImage(userDto.getProfileImage())
                .role(roleCustomer)
                .isActive(true)
                .build();

        if (userDto.getPhoneNumber() != null && !userDto.getPhoneNumber().trim().isBlank()) {
            newUser.setPhoneNumber(userDto.getPhoneNumber());
        } else if (userDto.getEmail() != null && !userDto.getEmail().trim().isBlank()) {
            newUser.setEmail(userDto.getEmail());
        }

        String password = userDto.getPassword();
        String encodedPassword = passwordEncoder.encode(password);
        newUser.setPassword(encodedPassword);

        return userRepository.save(newUser);
    }

    @Override
    public User createUserEmployee(UserDto userDto) throws Exception {
        if (userDto.getPhoneNumber() != null && !userDto.getPhoneNumber().trim().isBlank() &&
                userRepository.existsByPhoneNumber(userDto.getPhoneNumber()))
            throw new DataIntegrityViolationException("Phone number already exists");

        if (userDto.getEmail() != null && !userDto.getEmail().trim().isBlank() &&
                userRepository.existsByEmail(userDto.getEmail()))
            throw new DataIntegrityViolationException("Email already exists");

        Role roleEmployee = roleRepository.findById(Role.EMPLOYEE)
                .orElseThrow(() -> new DataNotFoundException("Role Employee does not exists"));

        User newUser = User.builder()
                .fullName(userDto.getFullName())
                .password(userDto.getPassword())
                .phoneNumber(userDto.getPhoneNumber())
                .email(userDto.getEmail())
                .address(userDto.getAddress())
                .dateOfBirth(userDto.getDateOfBirth())
                .role(roleEmployee)
                .isActive(true)
                .build();

        String password = userDto.getPassword();
        String encodedPassword = passwordEncoder.encode(password);
        newUser.setPassword(encodedPassword);

        return userRepository.save(newUser);
    }

    @Override
    public User createUserAdmin(UserDto userDto) throws Exception {
        if (userDto.getPhoneNumber() != null && !userDto.getPhoneNumber().trim().isBlank() &&
                userRepository.existsByPhoneNumber(userDto.getPhoneNumber()))
            throw new DataIntegrityViolationException("Phone number already exists");

        if (userDto.getEmail() != null && !userDto.getEmail().trim().isBlank() &&
                userRepository.existsByEmail(userDto.getEmail()))
            throw new DataIntegrityViolationException("Email already exists");

        Role roleAdmin = roleRepository.findById(Role.ADMIN)
                .orElseThrow(() -> new DataNotFoundException("Role Admin does not exists"));

        User newUser = User.builder()
                .fullName(userDto.getFullName())
                .password(userDto.getPassword())
                .phoneNumber(userDto.getPhoneNumber())
                .email(userDto.getEmail())
                .address(userDto.getAddress())
                .dateOfBirth(userDto.getDateOfBirth())
                .role(roleAdmin)
                .isActive(true)
                .build();

        String password = userDto.getPassword();
        String encodedPassword = passwordEncoder.encode(password);
        newUser.setPassword(encodedPassword);

        return userRepository.save(newUser);
    }

    @Override
    public String login(UserLoginDto userLoginDto) throws Exception {
        Optional<User> userOptional = Optional.empty();
        String subject = null;
        Role roleUser;

        if (userLoginDto.getRoleId() == null) {
            roleUser = roleRepository.findById(Role.CUSTOMER)
                    .orElseThrow(() -> new DataNotFoundException("Phone number or password is incorrect"));
        } else {
            roleUser = roleRepository.findById(userLoginDto.getRoleId())
                    .orElseThrow(() -> new DataNotFoundException("Phone number or password is incorrect"));
        }

        // Check if the user exists by phone number
        if (userLoginDto.getPhoneNumber() != null && !userLoginDto.getPhoneNumber().isBlank()) {
            userOptional = userRepository.findByPhoneNumber(userLoginDto.getPhoneNumber());
            subject = userLoginDto.getPhoneNumber();
        }

        if (userOptional.isEmpty()) {
            throw new DataNotFoundException("Phone number or password is incorrect");
        }
        User existingUser = userOptional.get();

        // Check password
        if (!passwordEncoder.matches(userLoginDto.getPassword(), existingUser.getPassword())) {
            throw new BadCredentialsException("Phone number or password is incorrect");
        }

        if (existingUser.getRole() != roleUser) {
            throw new DataNotFoundException("Phone number or password is incorrect");
        }

        // check user is active
        if (!existingUser.getIsActive()) {
            throw new DataNotFoundException(localizationUtils.getLocalizedMessage(MessageKeys.USER_IS_LOCKED));
        }

        UsernamePasswordAuthenticationToken authenticationToken = new UsernamePasswordAuthenticationToken(
                subject,
                userLoginDto.getPassword(),
                existingUser.getAuthorities()
        );

        authenticationManager.authenticate(authenticationToken);
        return jwtTokenUtils.generateToken(existingUser); // Return token
    }

    @Override
    public User getUserDetailsFromToken(String token) throws Exception {
        if (jwtTokenUtils.isTokenExpired(token)) {
            throw new Exception("Token is expired");
        }

        String subject = jwtTokenUtils.getSubject(token);
        Optional<User> userOptional = userRepository.findByPhoneNumber(subject);

        return userOptional.orElseThrow(() -> new Exception("User not found"));
    }

    @Override
    public User getUserDetailsFromRefreshToken(String refreshToken) throws Exception {
        Token existingToken = tokenRepository.findByRefreshToken(refreshToken);
        return getUserDetailsFromToken(existingToken.getToken());
    }

    @Override
    public User updateUser(UpdateUserDto updateUserDto, int userId) throws Exception {
        User existingUser = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        String newPhoneNumber = updateUserDto.getPhoneNumber();
        if (!existingUser.getPhoneNumber().equals(newPhoneNumber)
                && userRepository.existsByPhoneNumber(newPhoneNumber)) {
            throw new RuntimeException("Phone number already exists");
        }

        if (updateUserDto.getFullName() != null) {
            existingUser.setFullName(updateUserDto.getFullName());
        }
        if (updateUserDto.getPhoneNumber() != null) {
            existingUser.setPhoneNumber(updateUserDto.getPhoneNumber());
        }
        if (updateUserDto.getAddress() != null) {
            existingUser.setAddress(updateUserDto.getAddress());
        }
        if (updateUserDto.getDateOfBirth() != null) {
            existingUser.setDateOfBirth(updateUserDto.getDateOfBirth());
        }
        if (updateUserDto.getEmail() != null) {
            existingUser.setEmail(updateUserDto.getEmail());
        }

        // Update password
        if (updateUserDto.getPassword() != null && !updateUserDto.getPassword().isEmpty()) {
            if (!updateUserDto.getPassword().equals(updateUserDto.getRetypePassword())) {
                throw new DataNotFoundException("Password and retype password not the same");
            }
            String newPassword = updateUserDto.getPassword();
            String encodedPassword = passwordEncoder.encode(newPassword);
            existingUser.setPassword(encodedPassword);
        }

        return userRepository.save(existingUser);
    }

    @Override
    public Page<User> getAllUserCustomer(String keyword, Pageable pageable) throws Exception {
        return userRepository.findAll(keyword, pageable);
    }

    @Override
    @Transactional
    public void resetPassword(int userId, String newPassword) throws DataNotFoundException, InvalidPasswordException {
        User existingUser = userRepository.findById(userId)
                .orElseThrow(() -> new DataNotFoundException("User not found"));

        String encodedPassword = passwordEncoder.encode(newPassword);
        existingUser.setPassword(encodedPassword);
        userRepository.save(existingUser);

        // reset password => clear token
        List<Token> tokens = tokenRepository.findByUser(existingUser);
        for (Token token : tokens) {
            tokenRepository.delete(token);
        }
    }

    @Override
    @Transactional
    public void blockOrEnable(int userId, boolean active) throws DataNotFoundException {
        User existingUser = userRepository.findById(userId)
                .orElseThrow(() -> new DataNotFoundException("User not found"));
        existingUser.setIsActive(active);
        userRepository.save(existingUser);
    }

    @Override
    public void changeProfileImage(int userId, String imageName) throws Exception {
        User existingUser = userRepository.findById(userId)
                .orElseThrow(() -> new DataNotFoundException("User not found"));
        existingUser.setProfileImage(imageName);
        userRepository.save(existingUser);
    }

    @Override
    public User getUserByEmail(String email) throws Exception {
        if (StringUtils.isEmpty(email)) {
            throw new Exception("Email is empty");
        }
        Optional<User> optionalUser = userRepository.findByEmail(email);
        if (optionalUser.isEmpty()) {
            throw new DataNotFoundException("User not found");
        }
        return optionalUser.get();
    }
}
