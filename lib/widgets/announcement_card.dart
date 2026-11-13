import 'package:flutter/material.dart';

import '../constant/app_format.dart';
import '../constant/color.dart';
import '../model/announcement_data.dart';
import 'icon_box.dart';
import 'status_chip.dart';

// การ์ดประกาศ แตะเพื่อขยาย/ย่อเนื้อหา (เป็น StatefulWidget เพราะต้องจำว่าขยายอยู่หรือไม่)
class AnnouncementCard extends StatefulWidget {
  final AnnouncementData announcement;
  final VoidCallback? onDelete; // มีเฉพาะฝั่งผู้ดูแล

  const AnnouncementCard({
    super.key,
    required this.announcement,
    this.onDelete,
  });

  @override
  State<AnnouncementCard> createState() => _AnnouncementCardState();
}

class _AnnouncementCardState extends State<AnnouncementCard> {
  bool _isExpanded = false;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final AnnouncementData announcement = widget.announcement;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _toggleExpand,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconBox(
                    icon: announcement.isImportant
                        ? Icons.campaign_rounded
                        : Icons.notifications_none_rounded,
                    color: announcement.isImportant
                        ? dangerColor
                        : primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          announcement.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatDateTime(announcement.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // AnimatedSwitcher: สลับไอคอนลูกศรขึ้น/ลงแบบนุ่มนวล
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      key: ValueKey(_isExpanded),
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (announcement.isImportant) ...[
                const SizedBox(height: 10),
                const StatusChip(text: 'ประกาศสำคัญ', color: dangerColor),
              ],
              const SizedBox(height: 10),
              // ย่อ = แสดง 2 บรรทัด, ขยาย = แสดงทั้งหมด
              Text(
                announcement.content,
                maxLines: _isExpanded ? null : 2,
                overflow: _isExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, height: 1.6),
              ),
              if (widget.onDelete != null) ...[
                const SizedBox(height: 8),
                const Divider(height: 1),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: widget.onDelete,
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('ลบประกาศ'),
                    style: TextButton.styleFrom(foregroundColor: dangerColor),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
