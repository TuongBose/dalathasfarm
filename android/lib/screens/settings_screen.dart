import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _locationEnabled = false;
  bool _optionEnable = false;
  bool _notificationEnabled = true;
  String _language = 'Tiếng Việt';
  String _source = 'Galaxy Cinema phiên bản 3.5.17';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SwitchListTile(
                title: const Text('Vị trí hiện tại'),
                value: _locationEnabled,
                onChanged: (value) {
                  setState(() {
                    _locationEnabled = value;
                  });
                },
                activeColor: Colors.blue,
              ),

              SwitchListTile(
                title: const Text('Quyền thông báo'),
                value: _notificationEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationEnabled = value;
                  });
                },
                activeColor: Colors.blue,
              ),

              ListTile(
                title: const Text('Ngôn ngữ'),
                subtitle: Text(_language),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '10 nguồn',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
                onTap: () {
                  // TODO: Thêm logic để chọn ngôn ngữ
                },
              ),


              ListTile(
                title: const Text('Nguồn'),
                subtitle: Text(_source),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Thêm logic để chọn nguồn
                },
              ),

              const SizedBox(height: 20),

              SwitchListTile(
                title: const Text('Tùy chọn cập nhật'),
                value: _optionEnable,
                onChanged: (value) {
                  setState(() {
                    _optionEnable = value;
                  });
                },
                activeColor: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}