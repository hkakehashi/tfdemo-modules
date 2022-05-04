if (obj.status == 600) {
    set obj.status = 404;
    set obj.response = "Not Found";
    synthetic {"${html}"};
    return (deliver);
}